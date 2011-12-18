class MwsRequestsController < ApplicationController
  
  # GET /mws_requests
  # GET /mws_requests.json
  def index
    
		@mws_requests = MwsRequest.where('mws_request_id is null').order('created_at DESC').page(params[:page]).per(48)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @mws_requests }
    end
  end

  # GET /mws_requests/1
  # GET /mws_requests/1.json
  def show
    @mws_request = MwsRequest.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @mws_request }
    end
  end

end
