# frozen_string_literal: true

require 'test_helper'

class SequencescapeApiV2BaseTest < ActiveSupport::TestCase
  test 'find! returns records when find is not empty' do
    record = mock('record')
    Sequencescape::Api::V2::Base.stubs(:find).with({ id: '123' }).returns([record])

    result = Sequencescape::Api::V2::Base.find!(id: '123')

    assert_equal [record], result
  end

  test 'find! raises not found when find is empty' do
    Sequencescape::Api::V2::Base.stubs(:find).with({ id: 'missing' }).returns([])

    assert_raises(JsonApiClient::Errors::NotFound, 'Resource not found') do
      Sequencescape::Api::V2::Base.find!(id: 'missing')
    end
  end

  test 'all fetches all pages of results' do
    # While not representing actual objects, this is a good high-level summary of how the page fetching works
    result_set_1 = ['item1.1', 'item1.2', 'item1.3']
    result_set_2 = ['item2.1', 'item2.2', 'item2.3']
    result_set_3 = ['item3.1', 'item3.2', 'item3.3']

    third_page = build_page(result_set_3, next_page_url: nil)
    second_page = build_page(result_set_2, next_page: third_page, next_page_url: 'url_3')
    first_page = build_page(result_set_1, next_page: second_page, next_page_url: 'url_2')

    JsonApiClient::Resource.stubs(:all).returns(first_page)

    result = Sequencescape::Api::V2::Base.all

    expected = result_set_1 + result_set_2 + result_set_3
    assert_equal expected, result
  end

  def build_page(result_set, next_page: nil, next_page_url: nil) # rubocop:disable Metrics/MethodLength
    page = result_set.dup

    page_pages = stub('pages')
    page_pages.stubs(:next).returns(next_page)
    page_links = stub('links')
    if next_page_url
      page_links.stubs(:link_url_for).with('next').returns(next_page_url)
    else
      page_links.stubs(:link_url_for).with('next').raises(KeyError)
    end

    page.define_singleton_method(:pages) { page_pages }
    page.define_singleton_method(:links) { page_links }
    page.define_singleton_method(:concat) do |other_page|
      other_page.replace(self + other_page)
      other_page
    end

    page
  end
end
