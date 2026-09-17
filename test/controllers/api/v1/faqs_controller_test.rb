require "test_helper"

class Api::V1::FaqsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get api_v1_faqs_index_url
    assert_response :success
  end
end
