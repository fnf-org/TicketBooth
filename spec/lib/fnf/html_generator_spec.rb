# frozen_string_literal: true

require 'fnf/html_generator'

# rubocop: disable Layout/HeredocIndentation
module FnF
  RSpec.describe HTMLGenerator do
    let(:generator_without_simple_css) { described_class.new(simple_css: false) }
    let(:expected_without_simple_css) do
      <<~HTML
      <html>
        <body>
          <ol>
            <li>
              <strong>
                <a href="https://google.com"  target="_blank">
                  link 1
                </a>
              </strong>
            </li>
            <li>
              <strong>
                <a href="https://google.com"  target="_blank">
                  link 2
                </a>
              </strong>
            </li>
          </ol>
        </body>
      </html>
      HTML
    end

    let(:generator_with_simple_css) { described_class.new(simple_css: true) }
    let(:expected_with_simple_css) do
      <<~HTML
      <html>
        <head>
          <!-- Minified version -->
          <link rel="stylesheet" href="https://cdn.simplecss.org/simple.min.css">
        </head>
        <body>
          <ol>
            <li>
              <strong>
                <a href="https://google.com"  target="_blank">
                  link 1
                </a>
              </strong>
            </li>
            <li>
              <strong>
                <a href="https://google.com"  target="_blank">
                  link 2
                </a>
              </strong>
            </li>
          </ol>
        </body>
      </html>
      HTML
    end

    describe 'with a simple css header' do
      let(:html_block) do
        generator_with_simple_css.generate(:html) do
          body do
            ol do
              2.times do |number|
                li do
                  strong do
                    a href: 'https://google.com', target: '_blank' do
                      "link #{number + 1}"
                    end
                  end
                end
              end
              nil
            end
          end
        end
      end

      subject { html_block }

      it { is_expected.to eq(expected_with_simple_css) }
    end

    describe 'without simple css header' do
      let(:html_block) do
        generator_without_simple_css.generate(:html) do
          body do
            ol do
              2.times do |number|
                li do
                  strong do
                    a href: 'https://google.com', target: '_blank' do
                      "link #{number + 1}"
                    end
                  end
                end
              end
              nil
            end
          end
        end
      end

      subject { html_block }

      it { is_expected.to eq(expected_without_simple_css) }
    end
  end
end

# rubocop: enable Layout/HeredocIndentation
