# frozen_string_literal: true

# Since we don't exhaustively write view specs, make sure our controller specs
# always render the views (even though we don't check this output). This way
# we'll catch dumb rendering bugs even with controller specs, allowing us to
# write fewer view specs.
RSpec.configure(&:render_views)
