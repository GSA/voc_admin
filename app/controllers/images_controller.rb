class ImagesController < ApplicationController
  Images_Folder = "hhs_image_lib/"
  
  #show list of files
  def index
    @files = Dir["#{Rails.root}/public/images/#{Images_Folder}*"]
    @files.map! {|f| f.split('/').last}
    @files.sort!
  end
  
  def display
    return(redirect_to images_path) if params['file'].nil?
    @file = Images_Folder.to_s + params['file']
  end
  
  def new
  end
  
  def save_file
    return(redirect_to new_image_path) if params['upload']['datafile'].blank?
    name = params['upload']['datafile'].original_filename
    directory = "public/images/"+Images_Folder
    path = directory+name
    File.open(path, "wb") {|f| f.write(params['upload']['datafile'].read)}
    flash[:notice] = 'Image was successfully uploaded.'
    redirect_to images_path
  end
  
  #remove a file
  def remove
    return(redirect_to images_path) if params['file'].nil?
    File.delete("public/images/"+Images_Folder+params['file'])
    flash[:notice] = 'Image was successfully deleted.'
    redirect_to images_path
  end
end
