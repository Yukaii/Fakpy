class GalleryController < ApplicationController
  def index
    @images = Image.where(gender: 'female').weird.page(params[:page])
  end

  def about

  end
end
