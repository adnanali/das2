class MpController < ApplicationController
  def find
    @mp_info = Mp.get_mp_from_site(params[:postal_code])
    @var_name =  params[:var] || "mp_info"
    render :layout => false
  end

end
