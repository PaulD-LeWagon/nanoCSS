class FontsController < ApplicationController
  def index
    render json: { fonts: GoogleFontsService.catalogue }
  end
end
