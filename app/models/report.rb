require 'csv'

class Report 
	attr_accessor :type, :counting_id, :sample_ids, :species_ids,
    :view, :charts, :orientation, :show_symbols, :percentages,
    :column_criteria, :row_criteria
	attr_reader :column_headers, :row_headers, :values, :splits, :title

	QUANTITY = 'quantity'
	DENSITY = 'density'

	TYPES = [QUANTITY, DENSITY]
	VIEWS = [:numbers, :points, :blocks, :lines]

	TYPE_NAMES = {
		QUANTITY => 'Quantity',
    DENSITY => 'Density'
	}
	VIEW_NAMES = {
		:numbers => 'Numbers',
    :blocks => 'Blocks',
    :lines => 'Lines',
		:points => 'Points'
	}
  NOLATIN = /group|bisaccate|algae|pollens?|spores?|foraminiferal|test|linnings|other|and|acritarchs?|spp\.|sp\.|cf\.|[?()]|\d/i 

  ROUND = 1

	def initialize
		@params = [:well_id, :counting]
		@row_headers = []
		@column_headers = []
		@values = []
    @splits = []
	end

  def self.build( params )
    @report = Report.new
    @report.type = params[:type]
    @report.view = params[:view]
		@report.counting_id = params[:counting_id]
    @report.show_symbols = params[:show_symbols]
    @report.orientation = params[:orientation]
    @report.percentages = params[:percentages]
    @report.column_criteria = params[:columns]
    @report.row_criteria = params[:rows]

    @report
  end

	def name
		TYPE_NAMES[@type]
	end
	
	def has_param?( param )
		@params.include? param
	end

	def value_row
		@value_row = @values.each if @value_row.nil?
		@value_row
	end

  def make_column_values(column, rows, species)
    headers = []
    values = []
    transposed_rows = rows.transpose

    if column['species_ids']
      species.each_with_index do |species, i|
        if column['species_ids'].include?(species.id.to_s)
          col = []
          transposed_rows[i].each_with_index do |occurrence, j|
            col[j] = 
              if occurrence and occurrence.quantity and (occurrence.quantity > 0)
                occurrence
              else 
                nil
              end
          end
          headers << species.name
          values << col
        end
      end
      values = values.transpose

      case self.type
        when QUANTITY
          values.each_with_index do |row, i|
            row.each_with_index do |col, j|
              if col
                occurrence = values[i][j]
                values[i][j] = { 
                  occurrence: occurrence,
                  quantity: occurrence.quantity
                }
              end
            end
          end
        when DENSITY
          density_map = self.counting.occurrence_density_map
          values.each_with_index do |row, i|
            row.each_with_index do |col, j|
              if col
                occurrence = values[i][j]
                values[i][j] = { 
                  occurrence: occurrence,
                  quantity: density_map[occurrence] ? density_map[occurrence].round(ROUND) : 0
                }
              end
            end
          end
      end

      case column['merge'] 
        when 'sum'
          values.each_with_index do |row, i|
            v = row.inject(0) { |sum, v| sum + ((v.nil? or v[:quantity].nil?) ? 0 : v[:quantity]) }
            values[i] = [(v.is_a?( Float ) ? v.round(ROUND) : v).to_s]
          end
          headers = [column['header']]
          @splits << (@splits.last || -1) + 1
        when 'count'
          values.each_with_index do |row, i|
            values[i] = [row.inject(0) { |sum, v| sum + ((v.nil? or v[:quantity].nil?) ? 0 : 1) }.to_s]
          end
          headers = [column['header']]
          @splits << (@splits.last || -1) + 1
        else
          values.each_with_index do |row, i|
            row.each_with_index do |col, j|
              unless col.nil? 
                values[i][j] = if @show_symbols.to_i > 0
                  col[:occurrence].normal?? col[:quantity] : col[:occurrence].status_symbol
                else
                  col[:quantity]
                end.to_s + (col[:occurrence].uncertain?? Occurrence::UNCERTAIN_SYMBOL : '')
              else
                values[i][j] = '0'
              end
            end
          end
          @splits << (@splits.last || -1) + headers.size
      end

      @column_headers.concat headers
      values.each_with_index do |row, i|
        @values[i].concat row
      end
    end
  end

	def generate
    samples, species, occurrences = counting.summary
    rows = []
    @row_criteria.each_value do |row|
      samples.each_with_index do |sample, index|
        if row['sample_ids'].include?(sample.id.to_s)
          @row_headers << sample.name
          rows << occurrences[index]
          @values << []
        end
      end
    end
    @column_criteria.each_value do |column|
      make_column_values(column, rows, species)
    end

=begin
    if @percentages.to_i > 0
      @values.each_with_index do |row, index|
        counted = row.inject(0){ |sum, e| sum + e.to_i }
        row.each_with_index do |value, index|
          unless value.nil? 
            row[index] = (value.to_i*100.0/counted).round 
          end
        end
      end
    end
=end

    @column_criteria.each_value do |column|
      if column['computed'].present? and @column_criteria['0']['merge'].present? and @column_criteria['1']['merge'].present?
        a_idx = 0
        b_idx = 1
        if (column['computed'] =~ /^([ AB+\/()*-]|\d)+$/) == 0
          @values.each_with_index do |row, i|
            formula = column['computed'].dup
            a = row[a_idx]
            b = row[b_idx]

            formula.gsub!(/A/, a.to_f.to_s)
            formula.gsub!(/B/, b.to_f.to_s)
            begin
              result = eval formula
              @values[i] << result.round(ROUND).to_s
            rescue ZeroDivisionError
              @values[i] << ''
            end
          end
          @column_headers << column['header']
          @splits << (@splits.last || -1) + 1
        end
      end
    end
	end

	def self.model_name
		ActiveModel::Name.new( self, false )
	end

	def to_csv
		CSV.generate( col_sep: "," ) do |csv|
			csv << [nil].concat( @column_headers )
			@column_headers.each do |vheader|
				begin
					csv << [vheader].concat( self.value_row.next.map{ |i| (i.to_s == '0'? nil : i) } )
				rescue StopIteration => e
					csv << [vheader].concat( @column_headers.size.times.map{ |i| nil } )	
				end
			end
		end
	end

  def counting
    @counting = Counting.find self.counting_id if @counting.nil? && self.counting_id
    @counting
  end

end

