class OmxResponsesController < ApplicationController

	#around_filter :shopify_session
	
  # GET /omx_responses
  # GET /omx_responses.json
  def index
    @omx_responses = OmxResponse.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @omx_responses }
    end
  end

  # GET /omx_responses/1
  # GET /omx_responses/1.json
  def show
    @omx_response = OmxResponse.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @omx_response }
    end
  end

  # GET /omx_responses/new
  # GET /omx_responses/new.json
  def new
    @omx_response = OmxResponse.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @omx_response }
    end
  end

  # GET /omx_responses/1/edit
  def edit
    @omx_response = OmxResponse.find(params[:id])
  end

  # POST /omx_responses
  # POST /omx_responses.json
  def create
    @omx_response = OmxResponse.new(params[:omx_response])

    respond_to do |format|
      if @omx_response.save
        format.html { redirect_to @omx_response, notice: 'Omx response was successfully created.' }
        format.json { render json: @omx_response, status: :created, location: @omx_response }
      else
        format.html { render action: "new" }
        format.json { render json: @omx_response.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /omx_responses/1
  # PUT /omx_responses/1.json
  def update
    @omx_response = OmxResponse.find(params[:id])

    respond_to do |format|
      if @omx_response.update_attributes(params[:omx_response])
        format.html { redirect_to @omx_response, notice: 'Omx response was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @omx_response.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /omx_responses/1
  # DELETE /omx_responses/1.json
  def destroy
    @omx_response = OmxResponse.find(params[:id])
    @omx_response.destroy

    respond_to do |format|
      format.html { redirect_to omx_responses_url }
      format.json { head :ok }
    end
  end
end
