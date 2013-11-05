class ReportsController < ApplicationController
	before_filter :requires_user 
  layout :reports_layout

	respond_to :html
	respond_to :csv, :only => :export
	respond_to :pdf, :only => :export
	respond_to :svg, :only => :export

  def index
  end

  def new
		@report_type = params[:type]
  end

  def create
    @report = Report.build( params )
		@report.generate
		respond_with @report
  end

  def export
    @report = Report.build( params[:report] )
		@report.generate
		#respond_with @report
  end

  private
  def reports_layout
    ['create', 'export'].include?( params[:action] ) ? 'report' : 'application'
  end
end
