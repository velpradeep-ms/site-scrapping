require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'uri'

class ScrappingController < ApplicationController

  # Method for scrapping information from the given site by the user
  def index
    @images, @site_content = Scrapper.fetch_data params if params[:search_url].present?
    respond_to do |format|
      format.html {}
      format.js
    end
  end

  private

  # Never trust parameters from the scary internet, only allow the white list through.
  def resource_params
    params.require(:search_data).permit!
  end

end
