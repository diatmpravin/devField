class MwsResponsesController < ApplicationController
  
  around_filter :shopify_session
  
  # GET /mws_responses
  # GET /mws_responses.json
  def index
    @mws_responses = MwsResponse.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mws_responses }
    end
  end

  # GET /mws_responses/1
  # GET /mws_responses/1.json
  def show
    @mws_response = MwsResponse.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mws_response }
    end
  end

  # GET /mws_responses/new
  # GET /mws_responses/new.json
  def new
    @mws_response = MwsResponse.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @mws_response }
    end
  end

  # GET /mws_responses/1/edit
  def edit
    @mws_response = MwsResponse.find(params[:id])
  end

  # POST /mws_responses
  # POST /mws_responses.json
  def create
    @mws_response = MwsResponse.new(params[:mws_response])

    respond_to do |format|
      if @mws_response.save
        format.html { redirect_to @mws_response, notice: 'Mws response was successfully created.' }
        format.json { render json: @mws_response, status: :created, location: @mws_response }
      else
        format.html { render action: "new" }
        format.json { render json: @mws_response.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /mws_responses/1
  # PUT /mws_responses/1.json
  def update
    @mws_response = MwsResponse.find(params[:id])

    respond_to do |format|
      if @mws_response.update_attributes(params[:mws_response])
        format.html { redirect_to @mws_response, notice: 'Mws response was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @mws_response.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mws_responses/1
  # DELETE /mws_responses/1.json
  def destroy
    @mws_response = MwsResponse.find(params[:id])
    @mws_response.destroy

    respond_to do |format|
      format.html { redirect_to mws_responses_url }
      format.json { head :ok }
    end
  end
end
