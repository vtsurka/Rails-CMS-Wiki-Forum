class ContentPagesController < ApplicationController
  before_filter :require_admin_user, :except => [:home, :index, :show]
  
  def home
    @content_page = ContentPage.get_front_page
    render :action => :show
  end

  # GET /content_pages
  # GET /content_pages.xml
  def index
    @content_pages = ContentPage.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @content_pages }
    end
  end

  # GET /content_pages/1
  # GET /content_pages/1.xml
  def show
    @content_page = ContentPage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @content_page }
    end
  end

  # GET /content_pages/new
  # GET /content_pages/new.xml
  def new
    @content_page = ContentPage.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @content_page }
    end
  end

  # GET /content_pages/1/edit
  def edit
    @content_page = ContentPage.find(params[:id])
    @rel_dir = File.join "content_page_assets", "content_page_#{@content_page.id}"
    @assets = Dir[File.join(RAILS_ROOT, 'public', @rel_dir, '*')].map { |f| File.basename(f) }
  end

  # POST /content_pages
  # POST /content_pages.xml
  def create
    @content_page = ContentPage.new(params[:content_page])
    respond_to do |format|
      if @content_page.save
        if params[:new_category] and !params[:new_category].blank?
          cat = Category.find_or_create_by_name params[:new_category]
          @content_page.categories << cat
          @content_page.save
        end
        flash[:notice] = 'ContentPage was successfully created.'
        format.html { redirect_to(edit_content_page_path(@content_page)) }
        format.xml  { render :xml => @content_page, :status => :created, :location => @content_page }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @content_page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /content_pages/1
  # PUT /content_pages/1.xml
  def update
    @content_page = ContentPage.find(params[:id])
    respond_to do |format|
      if @content_page.update_attributes(params[:content_page])
        if params[:new_category] and !params[:new_category].blank?
          cat = Category.find_or_create_by_name params[:new_category]
          @content_page.categories << cat
          @content_page.save
        end
        flash[:notice] = 'ContentPage was successfully updated.'
        format.html { redirect_to(@content_page) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @content_page.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /content_pages/1
  # DELETE /content_pages/1.xml
  def destroy
    @content_page = ContentPage.find(params[:id])
    @content_page.destroy

    respond_to do |format|
      format.html { redirect_to(content_pages_url) }
      format.xml  { head :ok }
    end
  end


  def upload_handler
    @content_page = ContentPage.find params[:id]
    file_name = params[:upload].original_filename
    # break it up into file and extension
    # we need this to check the types and to build new names if necessary
    rel_dir = File.join "content_page_assets", "content_page_#{@content_page.id}"
    actual_dir = File.join(RAILS_ROOT, 'public', rel_dir)
    FileUtils.mkdir_p actual_dir
    File.open(File.join(actual_dir, file_name), 'wb') do |f|
      f.write(params[:upload].read)
    end

    render :text => "<html><body><script type=\"text/javascript\">" +
      "parent.CKEDITOR.tools.callFunction( #{params[:CKEditorFuncNum]}, '/#{rel_dir}/#{file_name}' )" +
      "</script></body></html>"
  end

  def delete_asset
    @content_page = ContentPage.find params[:id]
    file = File.join RAILS_ROOT, 'public', "content_page_assets", "content_page_#{@content_page.id}", params[:asset]
    if File.exists?(file) and File.delete(file)
      flash[:notice] = "#{File.basename(file)} deleted."
    else
      flash[:error] = "Unable to delete #{File.basename(file)}."
    end
    redirect_to edit_content_page_path(@content_page)
  end

  def search
    @search_phrase = params[:q]
    @content_pages = ContentPage.search @search_phrase 
    render :action => :index
  end
end