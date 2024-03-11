# frozen_string_literal: true

require 'fnf/html_generator'

module FnF
  RSpec.describe HTMLGenerator do
    let(:generator) { described_class.new }
    let(:expected) do
      '<html ><body ><ol ><li ><strong ><a  href="https://google.com" >0</a></strong></li><li ><strong ><a  href="https://google.com" >1</a></strong></li></ol></body></html>'
    end

    before do
      generator.generate do
        html do
          body do
            ol do
              2.times do |number|
                li do
                  strong do
                    a href: 'https://google.com' do
                      number
                    end
                  end
                end
              end
              nil
            end
          end
        end
      end
    end

    subject { generator.string }

    it { is_expected.to eq(expected) }
  end
end
