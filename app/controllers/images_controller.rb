# @author Communication Training Analysis Corporation <info@ctacorp.com>
#
# Allows for the management of user-uploaded images.
class ImagesController < ApplicationController
  # Define the directory used as an image repository.
  Images_Folder = "#{Rails.public_path}/images/hhs_image_lib/"

  # GET    /images(.:format)
  def index
    @files = Dir["#{Images_Folder}*"]
    @files.map! {|f| f.split('/').last}
    @files.sort!
  end

  # GET    /images/display(.:format)
  # Show a specific image.
  def display
    return(redirect_to images_path) if params['file'].nil?
    @file = params['file']
  end

  # GET    /images/new(.:format)
  def new
  end

  # POST   /images/save_file(.:format)
  # Upload the image.
  def save_file
    return(redirect_to new_image_path) if params['upload']['datafile'].blank?
    name = params['upload']['datafile'].original_filename
    directory = Images_Folder
    path = directory+name
    File.open(path, "wb") {|f| f.write(params['upload']['datafile'].read)}
    flash[:notice] = 'Image was successfully uploaded.'
    redirect_to images_path
  end

  # DELETE /images/remove(.:format)
  # Remove the image.
  def remove
    return(redirect_to images_path) if params['file'].nil?
    File.delete(Images_Folder+params['file'])
    flash[:notice] = 'Image was successfully deleted.'
    redirect_to images_path
  end
end
