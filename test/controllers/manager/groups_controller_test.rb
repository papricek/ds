require "test_helper"

class Manager::GroupsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @manager = create(:manager, account: @account, email: "manager@example.com", password: "password123")
    @group = create(:group, account: @account)
    login_as(@manager)
  end

  test "index lists groups" do
    get manager_groups_path
    assert_response :success
  end

  test "show displays group" do
    get manager_group_path(@group)
    assert_response :success
  end

  test "new renders form" do
    get new_manager_group_path
    assert_response :success
  end

  test "creates group" do
    assert_difference "Group.count", 1 do
      post manager_groups_path, params: { group: { name: "New Group", identifier: "NG-1" } }
    end
    assert_redirected_to manager_group_path(Group.last)
  end

  test "edit renders form" do
    get edit_manager_group_path(@group)
    assert_response :success
  end

  test "updates group" do
    patch manager_group_path(@group), params: { group: { name: "Updated" } }
    assert_redirected_to manager_group_path(@group)
    assert_equal "Updated", @group.reload.name
  end

  test "destroys group" do
    assert_difference "Group.count", -1 do
      delete manager_group_path(@group)
    end
    assert_redirected_to manager_groups_path
  end

  test "regular user cannot access groups" do
    delete session_path
    regular = create(:user, account: @account, email: "regular@example.com", password: "password123")
    login_as(regular)
    get manager_groups_path
    assert_redirected_to dashboards_path
  end

  private

  def login_as(user)
    post session_path, params: { email: user.email, password: "password123" }
  end
end
