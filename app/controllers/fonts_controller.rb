class FontsController < ApplicationController
  def index
    fonts = GoogleFontsService.catalogue

    if params[:q].present?
      query = params[:q].downcase
      fonts = fonts.select { |f| f.downcase.include?(query) }.first(20)
    else
      # If no query, return the first 20 common fonts, or if you want some standard ones:
      safe_fonts = [ "Inter", "Roboto", "Oswald", "Fira Code", "Merriweather", "Playfair Display", "Outfit", "Montserrat", "Lato", "Poppins" ]
      fonts = (safe_fonts + fonts).uniq.first(20)
    end

    render json: { fonts: fonts }
  end
end
