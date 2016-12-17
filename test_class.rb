require 'test/unit'
require 'selenium-webdriver'

    class TestRegistration < Test::Unit::TestCase
      def setup
        @driver = Selenium::WebDriver.for :firefox
        @wait = Selenium::WebDriver::Wait.new(:timeout => 10)
      end

      def registration_user
        @driver.navigate.to 'http://demo.redmine.org'
        @driver.find_element(:class, 'register').click
        @wait.until {@driver.find_element(:id, 'user_login').displayed?}
        @login = ('login' + rand(99999).to_s)
        @driver.find_element(:id, 'user_login').send_keys @login
        @current_password = 'password'
        @driver.find_element(:id, 'user_password').send_keys @current_password
        @driver.find_element(:id, 'user_password_confirmation').send_keys @current_password
        @first_name = 'Name' + rand(99).to_s
        @driver.find_element(:id, 'user_firstname').send_keys @first_name
        @last_name = 'Surname'
        @driver.find_element(:id, 'user_lastname').send_keys @last_name
        @driver.find_element(:id, 'user_mail').send_keys (@login + '@asdasdasd.ua')
        @driver.find_element(:name, 'commit').click
      end

      def test_registration
        registration_user
        @wait.until {@driver.find_element(:id, 'flash_notice').displayed?}
        expected_text = 'Your account has been activated. You can now log in.'
        actual_text = @driver.find_element(:id, 'flash_notice').text
        assert_equal(expected_text, actual_text)
      end
##################################################################################
      def login_user
        @driver.navigate.to 'http://demo.redmine.org'
        @driver.find_element(:class, 'login').click
        @wait.until {@driver.find_element(:id, 'username').displayed?}
        @driver.find_element(:id, 'username').send_keys @login
        @driver.find_element(:id, 'password').send_keys @current_password
        @driver.find_element(:name, 'login').click
      end

      def test_login_user
        registration_user
        login_user
        @wait.until {@driver.find_element(:id, 'loggedas').displayed?}
        expected_text = "Logged in as #{@login}"
        actual_text = @driver.find_element(:id, 'loggedas').text
        assert_equal(expected_text, actual_text)
      end
#################################################################################
      def logout_user
        @wait.until {@driver.find_element(:class, 'logout').displayed?}
        @driver.find_element(:class, 'logout').click
      end

      def test_logout_user
        registration_user
        login_user
        logout_user
        @wait.until {@driver.find_element(:class, 'login').displayed?}
        expected_button = 'Sign in'
        actual_button = @driver.find_element(:class, 'login').text
        assert_equal(expected_button, actual_button)
      end
###########################################################################################
      def change_password
        @wait.until {@driver.find_element(:class, 'my-account').displayed?}
        @driver.find_element(:class, 'my-account').click
        @wait.until {@driver.find_element(:xpath, "//*[text()='Change password']").displayed?}
        @driver.find_element(:xpath, "//*[text()='Change password']").click
        @wait.until {@driver.find_element(:id, 'password').displayed?}
        @driver.find_element(:id, 'password').send_keys @current_password
        new_password = (@current_password + rand(9).to_s)
        @driver.find_element(:id, 'new_password').send_keys new_password
        @driver.find_element(:id, 'new_password_confirmation').send_keys new_password
        @driver.find_element(:name, 'commit').click
        @current_password = new_password
      end

      def test_change_password
        registration_user
        login_user
        change_password
        @wait.until {@driver.find_element(:id, 'flash_notice').displayed?}
        expected_text = 'Password was successfully updated.'
        actual_text = @driver.find_element(:id, 'flash_notice').text
        assert_equal(expected_text, actual_text)
      end
#########################################################################################3
      def create_project
        #@wait.until {@driver.find_element(:xpath, "//*[text()='Projects']").displayed?}
        sleep(1)
        @driver.find_element(:class, 'projects').click
        sleep(1)
        @wait.until {!@driver.find_elements(:xpath, "//*[text()='New project']").empty?}
        @driver.find_element(:xpath, "//*[text()='New project']").click
        sleep(1)
        @wait.until {@driver.find_element(:id, 'project_name').displayed?}
        @project_name = 'Project' + rand(9999).to_s
        @driver.find_element(:id, 'project_name').send_keys @project_name
        @driver.find_element(:name, 'commit').click
      end

      def test_create_project
        registration_user
        login_user
        create_project
        @wait.until {@driver.find_element(:id, 'flash_notice').displayed?}
        expected_text = 'Successful creation.'
        actual_text = @driver.find_element(:id, 'flash_notice').text
        assert_equal(expected_text, actual_text)
      end
#####################################################################################
      def add_user_to_project
        @wait.until {@driver.find_element(:id, 'project_quick_jump_box').displayed?}
        @driver.find_element(:id, 'project_quick_jump_box').find_element(:xpath, "//*[text()='#{@project_name}']").click
        @wait.until {@driver.find_element(:class, 'settings').displayed?}
        @driver.find_element(:class, 'settings').click
        @wait.until {@driver.find_element(:id, 'tab-members').displayed?}
        sleep(1)
        @driver.find_element(:id, 'tab-members').click
        @driver.find_element(:xpath, "//*[text()='New member']").click
        @wait.until {@driver.find_element(:id, 'principal_search').displayed?}
        @driver.find_element(:id, 'principal_search').send_keys (@first_name_for_adding + ' ' + @last_name_for_adding)
        @wait.until {@driver.find_element(:xpath, "//*[text()=' #{@first_name_for_adding} #{@last_name_for_adding}']").displayed?}
        @driver.find_element(:xpath, "//*[text()=' #{@first_name_for_adding} #{@last_name_for_adding}']").click
        @driver.find_element(:xpath, "//*[text()=' Manager']").click
        @driver.find_element(:id, 'member-add-submit').click
      end

      def test_a_add_user_to_project
        registration_user
        @first_name_for_adding = @first_name
        @last_name_for_adding = @last_name
        logout_user
        sleep(1)
        registration_user
        login_user
        sleep (1)
        create_project
        add_user_to_project
        @wait.until {@driver.find_element(:xpath, "//*[text()=' #{@first_name_for_adding} #{@last_name_for_adding}']").displayed?}
        expected_user = "#{@first_name_for_adding} #{@last_name_for_adding}"
        actual_user = @driver.find_element(:xpath, "//*[text()=' #{@first_name_for_adding} #{@last_name_for_adding}']").text
        assert_equal(expected_user,actual_user)
      end
####################################################################################
      def create_project_version
        @driver.find_element(:id, 'project_quick_jump_box').find_element(:xpath, "//*[text()='#{@project_name}']").click
        sleep(2)
        @driver.find_element(:class, 'settings').click
        sleep(2)
        @driver.find_element(:id, 'tab-versions').click
        @driver.find_element(:xpath, "//*[text()='New version']").click
        @wait.until {@driver.find_element(:id, 'version_name').displayed?}
        new_version = 'Version #' + rand(99).to_s
        @driver.find_element(:id, 'version_name').send_keys new_version
        @driver.find_element(:name, 'commit').click
        @wait.until {@driver.find_element(:id, 'flash_notice').displayed?}
      end

      def test_create_project_version
        registration_user
        login_user
        create_project
        @wait.until {@driver.find_element(:id, 'project_quick_jump_box').displayed?}
        create_project_version
        expected_text = 'Successful creation.'
        actual_text = @driver.find_element(:id, 'flash_notice').text
        assert_equal(expected_text,actual_text)
      end
############################################################################################
      def bug_creation
        @driver.find_element(:id, 'project_quick_jump_box').find_element(:xpath, "//*[text()='#{@project_name}']").click
        sleep(2)
        @driver.find_element(:class, 'new-issue').click
        @wait.until {@driver.find_element(:id, 'issue_subject').displayed?}
        @driver.find_element(:id, 'issue_subject').send_keys 'some_summary'
        @driver.find_element(:name, 'commit').click
        @wait.until {@driver.find_element(:id, 'flash_notice').displayed?}
      end

      def test_bug_creation
        registration_user
        login_user
        @wait.until {@driver.find_element(:class, 'projects').displayed?}
        create_project
        @wait.until {@driver.find_element(:id, 'project_quick_jump_box').displayed?}
        bug_creation
        bug_number = @driver.find_element(:xpath, '//h2').text
        cut_bug_number = (bug_number[3, 9])
        expected_text = "Issue#{cut_bug_number} created."
        actual_text = @driver.find_element(:id, 'flash_notice').text
        assert_equal(expected_text,actual_text)
      end
#############################################################################################
      def feature_creation
        @driver.find_element(:id, 'project_quick_jump_box').find_element(:xpath, "//*[text()='#{@project_name}']").click
        sleep(1)
        @driver.find_element(:class, 'new-issue').click
        @wait.until {@driver.find_element(:id, 'issue_tracker_id').displayed?}
        @driver.find_element(:id, 'issue_tracker_id').find_element(:css,"option[value='2']").click
        @driver.find_element(:id, 'issue_subject').send_keys 'some_summary'
        @driver.find_element(:name, 'commit').click
        @wait.until {@driver.find_element(:id, 'flash_notice').displayed?}
      end

      def test_feature_creation
        registration_user
        login_user
        @wait.until {@driver.find_element(:class, 'projects').displayed?}
        create_project
        @wait.until {@driver.find_element(:id, 'project_quick_jump_box').displayed?}
        feature_creation
        bug_number = @driver.find_element(:xpath, '//h2').text
        cut_bug_number = (bug_number[7, 14])
        expected_text = "Issue#{cut_bug_number} created."
        actual_text = @driver.find_element(:id, 'flash_notice').text
        assert_equal(expected_text,actual_text)
      end
##############################################################################################
      def support_creation
        @driver.find_element(:id, 'project_quick_jump_box').find_element(:xpath, "//*[text()='#{@project_name}']").click
        sleep(1)
        @driver.find_element(:class, 'new-issue').click
        @wait.until {@driver.find_element(:id, 'issue_tracker_id').displayed?}
        @driver.find_element(:id, 'issue_tracker_id').find_element(:css,"option[value='3']").click
        @driver.find_element(:id, 'issue_subject').send_keys 'some_summary'
        @driver.find_element(:name, 'commit').click
        @wait.until {@driver.find_element(:id, 'flash_notice').displayed?}
      end

      def test_support_creation
        registration_user
        login_user
        @wait.until {@driver.find_element(:class, 'projects').displayed?}
        create_project
        @wait.until {@driver.find_element(:id, 'project_quick_jump_box').displayed?}
        feature_creation
        bug_number = @driver.find_element(:xpath, '//h2').text
        cut_bug_number = (bug_number[7, 15])
        expected_text = "Issue#{cut_bug_number} created."
        actual_text = @driver.find_element(:id, 'flash_notice').text
        assert_equal(expected_text,actual_text)
      end
#############################################################################################
      def edit_users_role
        @driver.find_element(:id, 'project_quick_jump_box').find_element(:xpath, "//*[text()='#{@project_name}']").click
        @wait.until {@driver.find_element(:class, 'settings').displayed?}
        sleep(1)
        @driver.find_element(:class, 'settings').click
        @wait.until {@driver.find_element(:id, 'tab-members').displayed?}
        sleep(1)
        @driver.find_element(:id, 'tab-members').click
        @wait.until {@driver.find_element(:xpath, "//*[text()='#{@first_name} #{@last_name}']").displayed?}

        if @driver.find_element(:xpath, "//*[text()='Manager']").displayed?
          @driver.find_element(:class, 'icon-edit').click
          @driver.find_element(:xpath, "//input[@name='membership[role_ids][]'] [@value=3]").click
          @driver.find_element(:xpath, "//input[@name='membership[role_ids][]'] [@value=5]").click
        else  @driver.find_element(:xpath, "//*[text()='Reporter']").displayed?
          @driver.find_element(:class, 'icon-edit').click
          @driver.find_element(:xpath, "//input[@name='membership[role_ids][]'] [@value=5]").click
          @driver.find_element(:xpath, "//input[@name='membership[role_ids][]'] [@value=3]").click
        end
        @driver.find_element(:xpath, "//p/input[@class='small']").click
      end

      def test_edit_users_role
        registration_user
        login_user
        sleep (1)
        create_project
        @wait.until {@driver.find_element(:id, 'project_quick_jump_box').displayed?}
        edit_users_role
        @wait.until {@driver.find_element(:xpath, '//td/span').displayed?}
        current_role = @driver.find_element(:xpath, '//td/span').text
        if current_role == 'Reporter'
          expected_role = current_role
        else
          expected_role = 'Manager'
        end
        actual_role = @driver.find_element(:xpath, '//td/span').text
        assert_equal(expected_role,actual_role)
      end

      def teardown
        @driver.quit
      end
    end
