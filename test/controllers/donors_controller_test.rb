require 'test_helper'


class DonorsControllerTest < ActionDispatch::IntegrationTest

  test "we return 409 status code in the event the donor email is already present in the db" do
    post donors_create_url, params: {donor: { email: "donor@donor.com", password: "does not matter",
                                                   address_zip: 90210 }}
    assert_response :conflict
  end

  test "we successfully register a new donor" do
    post donors_create_url, params: {donor: { email: "notindb@notindb.com", password: "password1!", first_name: "New",
                                              address_zip: 98104, account_status: AccountStatus::PROCESSING, last_name: "Donor",
                                              organization_name: "Uwajimaya", address_street: "600 5th Ave S",
                                              pickup_instructions: "On the back steps",
                                              address_city: "Seattle", address_state: "WA", business_license: "ADASDFG"}}
    assert_response :success
    just_added = Donor.find_by_email("notindb@notindb.com")
    assert_not_nil just_added
  end

  test "we register a new donor and account_status defaults to processing" do
    post donors_create_url, params: {donor: { email: "acc_status_test@notindb.com", password: "password1!", first_name: "New",
                                              address_zip: 98104, last_name: "Donor",
                                              organization_name: "Uwajimaya", address_street: "600 5th Ave S",
                                              pickup_instructions: "On the back steps",
                                              address_city: "Seattle", address_state: "WA", business_license: "ADASDFG"}}
    assert_response :success
    just_added = Donor.find_by_email("acc_status_test@notindb.com")
    assert_equal AccountStatus::PROCESSING, just_added.account_status, "account_status should default to #{AccountStatus::PROCESSING} if not specified"
  end

  test "data that fails donor registration returns an error response" do
    post donors_create_url, params: {donor: { email: "acc_status_notindb@notindb.com", password: "password", organization_name: "The Org",
                                                address_zip: 90210, first_name: "Newname", last_name: "Client"}}
    assert_response :bad_request
    res_obj = JSON.parse @response.body
    assert_equal 'Password is invalid', res_obj['errors'][0], 'should have returned invalid password'

  end

  test "we can update account_status for a donor" do
    patch '/donors/1/updateStatus', params: {status: AccountStatus::SUSPENDED}, headers: {'Authorization' => "Bearer #{JWT.encode({donor_id: 1}, Rails.application.secrets.secret_key_base)}"}
    assert_response :success
  end

  test "notify caller when donor already has requested status" do
    patch '/donors/1/updateStatus', params: {status: AccountStatus::ACTIVE}, headers: {'Authorization' => "Bearer #{JWT.encode({donor_id: 1}, Rails.application.secrets.secret_key_base)}"}
    assert_response 204
  end

  test "notify caller when requested donor status is invalid" do
    patch '/donors/1/updateStatus', params: {status: 'invalid!!'}, headers: {'Authorization' => "Bearer #{JWT.encode({donor_id: 1}, Rails.application.secrets.secret_key_base)}"}
    assert_response :bad_request
  end

end
