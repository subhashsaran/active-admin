ActiveAdmin.register AdminUser do

  after_create { |admin| admin.send_reset_password_instructions }
 
def password_required?
  new_record? ? false : super
end


  permit_params :email, :password, :password_confirmation

  
  index do
    selectable_column
    id_column
    column :email
    column :current_sign_in_at
    column :sign_in_count
    column :created_at
    actions
  end

  filter :email
  filter :current_sign_in_at
  filter :sign_in_count
  filter :created_at

  form do |f|
    f.inputs "Admin Details" do
      f.input :email
    end
  f.actions
  end



end
