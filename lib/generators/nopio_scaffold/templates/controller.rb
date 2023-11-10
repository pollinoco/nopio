# frozen_string_literal: true

class <%= controller_class_name %>Controller < ApplicationController
  before_action :authenticate_admin!
  theme 'dashboard'
  before_action :set_<%= singular_name %>, only: %i[show edit update destroy hard_destroy]

  def index
    add_breadcrumb I18n.t('backoffice.<%= plural_name %>')
    @<%= plural_name %> = <%= class_name %>.order(position: :asc)
    @pagy, @<%= plural_name %> = pagy(@<%= plural_name %>)
  end
  <% if show_action? -%>
  def show
    add_breadcrumb I18n.t('backoffice.<%= plural_name %>'), <%= plural_name %>_path
  end
  <% end -%>
  def new
    add_breadcrumb I18n.t('backoffice.<%= plural_name %>'), <%= plural_name %>_path
    add_breadcrumb I18n.t('backoffice.buttons.new_<%= singular_name %>')
    @<%= singular_name %> = <%= singular_name.build(class_name) %>
  end

  def edit
    add_breadcrumb I18n.t('backoffice.<%= plural_name %>'), <%= plural_name %>_path
    add_breadcrumb I18n.t('backoffice.buttons.edit_<%= singular_name %>')
  end

  def create
    @<%= singular_name %> = <%= class_name %>.new(<%= singular_name %>_params)
    respond_to do |format|
      if @<%= singular_name.save %>
        format.html { redirect_to @<%= singular_name %>, notice: t('<%= class_name.underscore.humanize %>.was_created') }
      else
        add_breadcrumb I18n.t('backoffice.<%= plural_name %>'), <%= plural_name %>_path
        add_breadcrumb I18n.t('backoffice.buttons.new_<%= singular_name %>')
        format.html { render :new }
      end
    end
  end

  def update
    respond_to do |format|
      if @<%= singular_name %>.update(<%= singular_name %>_params)
        format.html { redirect_to @<%= singular_name %>, notice: t('<%= class_name.underscore.humanize %>.was_updated') }
      else
        add_breadcrumb I18n.t('backoffice.<%= plural_name %>'), <%= plural_name %>_path
        add_breadcrumb I18n.t('backoffice.buttons.edit_<%= singular_name %>')
        format.html { render :edit }
      end
      format.json { respond_with_bip(@<%= singular_name %>) }
    end
  end

  def destroy
    @<%= singular_name %>.destroy
    respond_to do |format|
      format.html { redirect_to <%= plural_name %>_url, notice: t('<%= class_name.underscore.humanize %>.was_deleted') }
    end
  end

  def hard_destroy
    @<%= singular_name %>.really_destroy!
    respond_to do |format|
      format.html { redirect_to <%= plural_name %>_url, notice: t('<%= class_name.underscore.humanize %>.was_deleted') }
    end
  end

  def sort
    params[:<%= singular_name %>].each_with_index do |id, index|
      <%= class_name %>.where(id:).update_all(position: index + 1)
    end
    head :ok
  end

  private

  def set_<%= singular_name %>
    @<%= singular_name %> = <%= class_name %>.where('hash_code = ?', params[:id]).first
    redirect_if_not_found('<%= class_name %> no existe en set_<%= singular_name %>') if @<%= singular_name %>.blank?
  end

  def <%= singular_name %>_params
    params.require(:<%= singular_name %>).permit(<%= editable_attributes.map { |a| a.name.prepend(':') }.join(', ') %>)
  end
end