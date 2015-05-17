class GalleryController < ApplicationController
  def index
    @images = Image.weird.page(params[:page])
  end
end
