class ReportsController < ApplicationController
	before_filter :requires_user
  layout :reports_layout

  def index
  end

  def new
		@report_type = params[:type]
  end

  def create
    @report = Report.build( params )
		@report.generate
  end

  def export
    @report = Report.build( params[:report] )
		@report.generate
    respond_to do |format|
      format.csv
      format.pdf
      format.svg
      format.html
    end
  end

  private
  def reports_layout
    ['create', 'export'].include?( params[:action] ) ? 'report' : 'application'
  end
end
