require 'test_helper'

module Hubification
  class SplashControllerTest < ActionController::TestCase
    test "should get index" do
      get :index
      assert_response :success
    end
  
  end
end
