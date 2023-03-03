# frozen_string_literal: true

require 'test_helper'
require 'mock_api'

class MakeQcDecisionTest < ActionDispatch::IntegrationTest
  include MockApi

  def prepare_decision(decision)
    visit new_batch_qc_decision_path('12345')

    api.qc_decision.expect_create_with(
      received: {
        user: '11111111-2222-3333-4444-555555555555',
        lot: '11111111-2222-3333-4444-555555555556',
        decisions: [
          { 'qcable' => '11111111-2222-3333-4444-100000000008', 'decision' => decision }, # Was pending
          { 'qcable' => '11111111-2222-3333-4444-100000000009', 'decision' => decision }  # Was pending
        ]
      },
      returns: '11111111-2222-3333-9999-330000000008'
    )
    fill_in('User swipecard', with: 'abcdef').send_keys(:tab)

    # Check user been copied to the individual batch forms
    find('td[data-lot-uuid="11111111-2222-3333-4444-555555555556"] input[name="user_swipecard"][value="abcdef"]', visible: :any)
  end

  setup do
    mock_api
    api.mock_user('abcdef', '11111111-2222-3333-4444-555555555555')

    lot = api.lot.with_uuid('11111111-2222-3333-4444-555555555556')

    lot.stubs(:pending_qcable_uuids).returns(%w[
                                               11111111-2222-3333-4444-100000000008
                                               11111111-2222-3333-4444-100000000009
                                             ])

    # We mock here, as this is out interface with the controller.

    api.search.with_uuid('d8986b60-b104-11e3-a4d5-44fb42fffecc')
       .expects(:all)
       .with(Gatekeeper::Lot, batch_id: '12345')
       .returns([lot])
  end

  test 'release lot' do
    prepare_decision('release')

    click_button('Release lot')

    # Ajax success
    assert_equal true, find(:xpath, '//td[@data-lot-uuid="11111111-2222-3333-4444-555555555556"]/../td[@class="decision"]').has_content?('0')

    # Released correctly
    assert_equal true, find('td[data-lot-uuid="11111111-2222-3333-4444-555555555556"]').has_content?('Release')
  end

  test 'fail lot' do
    prepare_decision('fail')

    click_button('Fail lot')

    # Ajax success
    assert_equal true, find(:xpath, '//td[@data-lot-uuid="11111111-2222-3333-4444-555555555556"]/../td[@class="decision"]').has_content?('0')

    # Failed correctly
    assert_equal true, find('td[data-lot-uuid="11111111-2222-3333-4444-555555555556"]').has_content?('Fail')
  end

  test 'release all lots' do
    prepare_decision('release')

    click_button('Release All Lots')

    # Ajax success
    assert_equal true, find(:xpath, '//td[@data-lot-uuid="11111111-2222-3333-4444-555555555556"]/../td[@class="decision"]').has_content?('0')

    # Released correctly
    assert_equal true, find('td[data-lot-uuid="11111111-2222-3333-4444-555555555556"]').has_content?('Release')
  end

  test 'fail all lots' do
    prepare_decision('fail')

    click_button('Fail All Lots')

    # Ajax success
    assert_equal true, find(:xpath, '//td[@data-lot-uuid="11111111-2222-3333-4444-555555555556"]/../td[@class="decision"]').has_content?('0')

    # Failed correctly
    assert_equal true, find('td[data-lot-uuid="11111111-2222-3333-4444-555555555556"]').has_content?('Fail')
  end
end
