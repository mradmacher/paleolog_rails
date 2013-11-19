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

  def filter_row( filter, samples, occurrences )
    filtered_samples = []
    filtered_occurrences = []
    samples.each_with_index do |sample, index|
      if filter['sample_ids'].include?(sample.id.to_s)
        filtered_samples << sample
        filtered_occurrences << occurrences[index]
      end
    end
    [filtered_samples, filtered_occurrences]
  end

  def filter_column( filter, species, occurrences )
    filtered_species = []
    filtered_occurrences = []

    if filter['species_ids']
      transposed = occurrences.transpose
      species.each_with_index do |species, i|
        if filter['species_ids'].include?(species.id.to_s)
          col = []
          transposed[i].each_with_index do |occurrence, j|
            col[j] =
              if occurrence and occurrence.quantity and (occurrence.quantity > 0)
                occurrence
              else
                nil
              end
          end
          filtered_species << species
          filtered_occurrences << col
        end
      end
      filtered_occurrences = filtered_occurrences.transpose
    end
    [filtered_species, filtered_occurrences]
  end

  def process_column( criteria, species, occurrences )
    headers = []
    values = []
    unless species.empty?
      species.each do |s|
        headers << s.name
      end
      density_map = self.counting.occurrence_density_map if self.type == DENSITY

      occurrences.each_with_index do |row, i|
        values[i] = []
        row.each_with_index do |col, j|
          if col
            values[i][j] = {
              occurrence: col,
              quantity: if self.type == DENSITY
                  density_map[col] ? density_map[col].round(ROUND) : 0
                else
                  col.quantity
                end
            }
          else
            values[i][j] = nil
          end
        end
      end
    end
    [headers, values]
  end

  def merge_column( criteria, headers, values )
    unless headers.empty?
      case criteria['merge']
        when 'sum'
          values.each_with_index do |row, i|
            v = row.inject(0) { |sum, v| sum + ((v.nil? or v[:quantity].nil?) ? 0 : v[:quantity]) }
            values[i] = [(v.is_a?( Float ) ? v.round(ROUND) : v).to_s]
          end
          headers = [criteria['header']]
          @splits << (@splits.last || -1) + 1
        when 'count'
          values.each_with_index do |row, i|
            values[i] = [row.inject(0) { |sum, v| sum + ((v.nil? or v[:quantity].nil?) ? 0 : 1) }.to_s]
          end
          headers = [criteria['header']]
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
    end
    [headers, values]
  end

  def process_computed_column( criteria )
    headers = []
    values = []
    if criteria['computed'].present? and @column_criteria['0']['merge'].present? and @column_criteria['1']['merge'].present?
      a_idx = 0
      b_idx = 1
      if (criteria['computed'] =~ /^([ AB+\/()*-]|\d)+$/) == 0
        @values.each_with_index do |row, i|
          formula = criteria['computed'].dup
          a = row[a_idx]
          b = row[b_idx]

          formula.gsub!(/A/, a.to_f.to_s)
          formula.gsub!(/B/, b.to_f.to_s)
          begin
            result = eval formula
            values[i] = [result.round(ROUND).to_s]
          rescue ZeroDivisionError
            values[i] = ['']
          end
        end
        headers << criteria['header']
        @splits << (@splits.last || -1) + 1
      end
    end
    [headers, values]
  end

  def concat_values( values )
    unless values.empty?
      values.each_with_index do |row, i|
        @values[i].concat( row )
      end
    end
  end

  def concat_column_headers( headers )
    unless headers.empty?
      @column_headers.concat( headers )
    end
  end

	def generate
    samples, species, occurrences = counting.summary

    @row_criteria.each_value do |criteria|
      samples, occurrences = filter_row( criteria, samples, occurrences )
      samples.each do |sample|
        @row_headers << sample.name
        @values << []
      end
    end

    @column_criteria.each_value do |criteria|
      filtered_species, filtered_occurrences = filter_column( criteria, species, occurrences )
      headers, values = process_column( criteria, filtered_species, filtered_occurrences )
      headers, values = merge_column( criteria, headers, values )

      concat_column_headers( headers )
      concat_values( values )
    end

    @column_criteria.each_value do |criteria|
      headers, values = process_computed_column( criteria )

      concat_column_headers( headers )
      concat_values( values )
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

