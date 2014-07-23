# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# GENE Gyrokinetic Electromagnetic Numerical Experiment Input Parameters
# >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
# Code: 		gene
# System: 	generic_linux
# Version:	
# Nprocs: 	4
# Directory:	/home/edmundhighcock/Mac/Simulations/gene/test/linear_jet_75225/v/id_16
# Runname:	v_istep_omega_10_ntimesteps_10000_omega_prec_0.01_adapt_lx_.true._nky0_1_nx0_4_omt_1_1.5_write_h5_.true._id_16
# ID:		16
#  
# Classname:	CodeRunner::Gene

# Job_No:		7321

# Parameters:
{:diagdir=>".",
 :read_checkpoint=>".F.",
 :istep_schpt=>5000,
 :istep_field=>250,
 :istep_mom=>500,
 :istep_nrg=>10,
 :istep_vsp=>500,
 :istep_omega=>10,
 :istep_energy=>500,
 :write_h5=>".true.",
 :nx0=>4,
 :nky0=>1,
 :nz0=>12,
 :nv0=>8,
 :nw0=>8,
 :n_spec=>4,
 :lx=>250,
 :kymin=>0.05,
 :lv=>3.0,
 :lw=>9.0,
 :adapt_lx=>".true.",
 :x0=>0.33,
 :nonlinear=>".F.",
 :comp_type=>"IV",
 :calc_dt=>".T.",
 :ntimesteps=>10000,
 :timelim=>42400,
 :omega_prec=>0.01,
 :beta=>0.0,
 :debye2=>0,
 :bpar=>".T.",
 :coll=>7.978e-05,
 :collision_op=>"landau",
 :coll_cons_model=>"xu_rosenbluth",
 :hyp_z=>15.0,
 :hyp_v=>0.2,
 :exbrate=>0.0,
 :pfsrate=>-1111,
 :exb_stime=>100,
 :magn_geometry=>"tracer_efit",
 :geomdir=>"../..",
 :geomfile=>"JET75225_Ptot",
 :dpdx_term=>"full_drift",
 :dpdx_pm=>-1,
 :name_1=>"Ions",
 :omn_1=>0.82405063,
 :omt_1=>1.5,
 :mass_1=>1.0,
 :charge_1=>1,
 :temp_1=>1.19,
 :dens_1=>0.79,
 :name_2=>"Carbon",
 :omn_2=>1.02,
 :omt_2=>2.57,
 :mass_2=>6.0,
 :charge_2=>6,
 :temp_2=>1.19,
 :dens_2=>0.015,
 :name_3=>"Fast",
 :omn_3=>2.31,
 :omt_3=>0.108,
 :mass_3=>1.0,
 :charge_3=>1,
 :temp_3=>7.3,
 :dens_3=>0.12,
 :name_4=>"Electrons",
 :omn_4=>1.02,
 :omt_4=>1.47,
 :mass_4=>0.0002725,
 :charge_4=>-1,
 :temp_4=>1.0,
 :dens_4=>1.0,
 :tref=>4.8,
 :nref=>3.92,
 :lref=>1.21,
 :bref=>2.03,
 :mref=>2,
 :n_procs_s=>-1,
 :n_procs_w=>-1,
 :n_procs_v=>-1,
 :n_procs_z=>-1,
 :n_procs_y=>-1,
 :n_procs_x=>-1,
 :n_procs_sim=>4,
 :job_no=>7321,
 :id=>16,
 :sys=>"generic_linux",
 :naming_pars=>
  [:istep_omega,
   :ntimesteps,
   :omega_prec,
   :adapt_lx,
   :nky0,
   :nx0,
   :omt_1,
   :write_h5],
 :run_name=>
  "v_istep_omega_10_ntimesteps_10000_omega_prec_0.01_adapt_lx_.true._nky0_1_nx0_4_omt_1_1.5_write_h5_.true._id_16",
 :parameter_hash=>
  {:istep_omega=>10,
   :ntimesteps=>10000,
   :omega_prec=>0.01,
   :adapt_lx=>".true.",
   :nky0=>1,
   :nx0=>4,
   :omt_1=>1.5,
   :write_h5=>".true."},
 :parameter_hash_string=>
  "{istep_omega: 10, ntimesteps: 10000, omega_prec: 0.01,  adapt_lx: \".true.\", nky0: 1, nx0: 4, omt_1: 1.5, write_h5: \".true.\"}",
 :output_file=>"gene_ubuntu_gfortran.16.o",
 :error_file=>"gene_ubuntu_gfortran.16.e",
 :nprocs=>"4",
 :executable=>"/home/edmundhighcock/Build/gene/bin/gene_ubuntu_gfortran",
 :code=>"gene"}



# Actual Command:
# time mpirun -np 4 /home/edmundhighcock/Build/gene/bin/gene_ubuntu_gfortran  > gene_ubuntu_gfortran.16.o 2> gene_ubuntu_gfortran.16.e
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
