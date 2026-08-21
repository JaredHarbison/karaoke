# frozen_string_literal: true

# Application-wide, role-aware help.
class HelpController < ApplicationController
  before_action :authenticate_user!

  def index
    @guides = HelpGuideCatalog.for(current_user)
  end
end
