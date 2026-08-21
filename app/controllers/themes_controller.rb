# frozen_string_literal: true

# Manages reusable theme definitions for the current venue.
class ThemesController < ApplicationController
  before_action :authenticate_user!
  before_action :require_current_venue!
  before_action :require_admin!
  before_action :set_theme, only: %i[edit update destroy]

  def index
    @themes = Current.venue.themes.order(:name)
  end

  def new
    @theme = Current.venue.themes.new
  end

  def create
    @theme = Current.venue.themes.new(theme_params)

    if @theme.save
      redirect_to venue_themes_path(Current.venue.slug), notice: 'Theme created.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @theme.update(theme_params)
      redirect_to venue_themes_path(Current.venue.slug), notice: 'Theme updated.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @theme.destroy
    redirect_to venue_themes_path(Current.venue.slug), notice: 'Theme removed.'
  end

  private

  def set_theme
    @theme = Current.venue.themes.find(params[:id])
  end

  def theme_params
    params.require(:theme).permit(:name, :description, :active)
  end
end
