class DoctorsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :index]
  before_action :set_doctor, only: [:show, :edit, :update, :destroy]

  def index
    @specialities = Specialty.all
    @doctors = Doctor.all
    @doctors_quartet = @doctors.each_slice(4).to_a

    unless params[:query].nil?
      @selected_doctors = @doctors.select do |doc|
        doc_spec = doc.specialties[0].name
        query = params[:query].capitalize

        doc_spec.include?(query)
      end
      @selected_quartet = @selected_doctors.each_slice(4).to_a
    end
  end

  def new
    @specialties = Specialty.all
    @doctor = Doctor.new
  end

  def create
    @doctor = Doctor.new(doctor_params)
    @doctor.user = current_user
    unless current_user.doctor
      if @doctor.save!
        current_user.doctor = @doctor
        current_user.save!
        redirect_to doctor_path(@doctor)
      else
        render :new
      end
    else
      redirect_to doctor_path(current_user.doctor)
    end
  end

  def show
    set_doctor
  end

  def edit
    redirect_to root_path if current_user != @doctor.user
    @specialties = Specialty.all
    set_doctor
  end

  def update

    if @doctor.update(doctor_params)
      DoctorSpecialty.where(doctor: @doctor).destroy_all
      params[:doctor][:specialty_ids].each do |specialty_id|
        specialty = Specialty.find(specialty_id)
        DoctorSpecialty.create(doctor: @doctor, specialty: specialty)
      end
      redirect_to doctor_path(@doctor)
    else
      render :new
    end
  end

  def destroy
    redirect_to root_path if current_user != @doctor.user
    set_doctor
    @doctor.destroy
    redirect_to root_path
  end

  private

  def doctor_params
    params.require(:doctor).permit(:professional_register, :address)
  end

  def set_doctor
    @doctor = Doctor.find(params[:id])
  end
end
