require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def test_index
    get :index
    assert_template 'index'
  end

  def test_show
    get :show, :id => User.first
    assert_template 'show'
  end
end
