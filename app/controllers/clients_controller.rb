class ClientsController < ApplicationController
  skip_before_action :authorized, only: [:create, :update]

  def index
    @clients = Client.all
  end

  def show
  end

  def new
  end

  def create
    return render json: { error: 'client email already in use'}, status: :conflict if Client.exists?({email: client_params(false)[:email]})
    params['client']['account_status'] = 'processing'
    @client = Client.create!(client_params(true))
    if @client.valid?
      @token = encode_token(client_id: @client.id)
      render json: { client: ClientSerializer.new(@client), jwt: @token }, status: :created
    else
      render json: { error: 'failed to create client' }, status: :unprocessable_entity
    end
  end

  def activate
      id = params[:id].to_i

      @client = Client.find(id)
      status = @client.account_status

      failure_message = { error: "Client id: #{id} status not changed to active.  Remained: #{@client.account_status}" }

      if status == 'approved'
        success_message = { message: "Client id: #{id} status changed to active. Was: #{status}" }
        success = @client.update_attribute(:account_status, 'active')
      elsif status == 'active'
          success_message = { message: "Client id: #{id} status was not updated as the user is already active" }
          success = true
      else
          success = false
      end

      success ?
          (render json: success_message, status: :ok) :
          (render json: failure_message, status: :bad_request)
  end
  
  def account_status_update
      id = params[:id].to_i
      status = params[:status]

      @client = Client.find(id)
      success_message = { message: "Client id: #{id} status changed to #{status}. Was: #{@client.account_status}" }
      failure_message = { error: "Client id: #{id} status not changed to #{status}.  Remained: #{@client.account_status}" }

      case status
      when 'approved'
          success = @client.update_attribute(:account_status, 'approved')
      when 'processing'
          success = @client.update_attribute(:account_status, 'processing')
      when 'active'
          success = @client.update_attribute(:account_status, 'active')
      when 'suspended'
          success = @client.update_attribute(:account_status, 'suspended')
      end

      success ?
          (render json: success_message, status: :ok) :
          (render json: failure_message, status: :unprocessable_entity)
  end

  def update
    @client = Client.find(params[:id])
    if @client.update(client_params(false))
      render json: @client
    else
      failure_message = { error: "Client id: #{params[:id]} was not updated. #{@client.errors.full_messages}" }
      puts failure_message
      render json: failure_message
    end
  end

  def get_donations
    if !params[:client_lat] || !params[:client_long]
      render json: { error: 'Missing client_lat and/or client_long params' }, status: :unprocessable_entity
      return
    end

    client_lat = params[:client_lat].to_f
    client_long = params[:client_long].to_f

    # TODO - transportation_method column was removed from Client table
    # mode = Client.find(params[:id].to_i).transportation_method 

    @distance = 100.0
    # case mode
    # when 'walk'
    #   @distance = 1.0
    # when 'bike'
    #   @distance = 5.0
    # when 'public'
    #   @distance = 5.0
    # when 'car'
    #   @distance = 20.0
    # end

    puts 'travel distance:', @distance

    @available = Donation.all.select do |d|
      # Check if each donation is still active based on the time it was created and its duration.
      # Time.now comes back in seconds, so we divide by 60 to compare in minutes.

      # NOTE: For testing purposes, we are returning all donations, so we don't have to keep creating new ones.
      # NOTE: Uncomment the next line when that is ready to change.
      # (Time.now - d.created_at) / 60 < d.duration_minutes

      # NOTE: Kill next line when making the above change.
      true
    end

    # Uncomment the below code to limit donations by distance.
    # @reachable = @available.select do |donation|
    #   # Check @distance from client to donor of donation
    #   donor = Donor.find(donation.donor_id)
    #   donor.distance_to([client_lat, client_long]) <= @distance
    # end

    # HACK: shows all donations while we are in test mode.  Remove this when uncommenting the above code.
    @reachable = @available

    puts 'reachable:', @reachable.map(&:food_name)
    render json: @reachable, include: 'claims', status: :ok
  end

  def get_claims
    @user = Client.find(params[:id])
    @claims = @user.claims
    @claims_to_return = @claims.as_json
    @claims.each_with_index { |claim, i|
      @claims_to_return[i]['address'] = claim.donation.donor.address
      @claims_to_return[i]['donor'] = claim.donation.donor.organization_name
      @claims_to_return[i]['donation'] = claim.donation.as_json
    }
    render json: @claims_to_return, status: :ok
  end

  private

  def client_params(shouldPermitAccountStatus)
    if shouldPermitAccountStatus
        params.require(:client).permit(
          :email,
          :password,
          :first_name,
          :last_name,
          :account_status,
          #:address_street,
          #:address_city,
          #:address_zip,
          #:address_state,
          #:ethnicity,
          #:gender
        )
    else
      params.require(:client).permit(
        :email,
        :password,
        :first_name,
        :last_name,
        #:account_status,
        #:address_street,
        #:address_city,
        #:address_zip,
        #:address_state,
        #:ethnicity,
        #:gender
      )
    end
  end
end

