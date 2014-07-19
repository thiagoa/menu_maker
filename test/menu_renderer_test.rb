require 'test_helper'
require 'ostruct'

module MenuMaker
  class MenuRendererTest < ActiveSupport::TestCase
    context 'supplied context has a request' do
      ContextStub = begin
        request_stub = Class.new do
          def method; 'POST'  end
          def path;   '/path' end
        end.new

        OpenStruct.new request: request_stub
      end

      context 'an explicit path is not supplied' do
        should 'get the path from the request' do
          renderer = MenuRenderer.new(ContextStub, nil)
          assert_equal Path.new(:post, '/path'), renderer.current_path
        end
      end

      context 'an explicit path is supplied' do
        should 'not get the path from the request' do
          renderer = MenuRenderer.new(ContextStub, '/other')
          assert_equal Path.new(:get, '/other'), renderer.current_path
        end
      end
    end
  end
end
