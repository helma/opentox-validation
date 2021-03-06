
#[ 'rubygems', 'datamapper' ].each do |lib|
#  require lib
#end
require "lib/merge.rb"

unless ActiveRecord::Base.connected?
  ActiveRecord::Base.establish_connection(  
     :adapter => @@config[:database][:adapter],
     :host => @@config[:database][:host],
     :database => @@config[:database][:database],
     :username => @@config[:database][:username],
     :password => @@config[:database][:password]
  )
  ActiveRecord::Base.logger = Logger.new("/dev/null")
end

module Lib

  VAL_PROPS_GENERAL = [ :validation_uri, :model_uri, :algorithm_uri, :training_dataset_uri, :prediction_feature,
                :test_dataset_uri, :test_target_dataset_uri, :prediction_dataset_uri, :created_at ] 
  VAL_PROPS_SUM = [ :num_instances, :num_without_class, :num_unpredicted ]
  VAL_PROPS_AVG = [:real_runtime, :percent_without_class, :percent_unpredicted ]
  VAL_PROPS = VAL_PROPS_GENERAL + VAL_PROPS_SUM + VAL_PROPS_AVG
  
  # :crossvalidation_info
  VAL_CV_PROPS = [ :crossvalidation_id, :crossvalidation_uri, :crossvalidation_fold ]
  
  # :classification_statistics
  VAL_CLASS_PROPS_SINGLE_SUM = [ :num_correct, :num_incorrect, :confusion_matrix  ]
  VAL_CLASS_PROPS_SINGLE_AVG = [ :percent_correct, :percent_incorrect, :weighted_area_under_roc ]
  VAL_CLASS_PROPS_SINGLE = VAL_CLASS_PROPS_SINGLE_SUM + VAL_CLASS_PROPS_SINGLE_AVG
  
  # :class_value_statistics
  VAL_CLASS_PROPS_PER_CLASS_SUM = [ :num_false_positives, :num_false_negatives, 
                                :num_true_positives, :num_true_negatives ]
  VAL_CLASS_PROPS_PER_CLASS_AVG = [ :area_under_roc, :false_negative_rate, :false_positive_rate,
                                :f_measure, :precision, 
                                :true_negative_rate, :true_positive_rate ] #:recall,
  VAL_CLASS_PROPS_PER_CLASS = VAL_CLASS_PROPS_PER_CLASS_SUM + VAL_CLASS_PROPS_PER_CLASS_AVG
  VAL_CLASS_PROPS_PER_CLASS_COMPLEMENT_EXISTS = [ :num_false_positives, :num_false_negatives, 
                                :num_true_positives, :num_true_negatives, :false_negative_rate, :false_positive_rate,
                                :true_negative_rate, :true_positive_rate ] #:precision, :recall, 
                                
  VAL_CLASS_PROPS = VAL_CLASS_PROPS_SINGLE + VAL_CLASS_PROPS_PER_CLASS
  VAL_CLASS_PROPS_EXTENDED = VAL_CLASS_PROPS + [:accuracy]

  # :regression_statistics
  VAL_REGR_PROPS = [ :root_mean_squared_error, :mean_absolute_error, :r_square, 
    :target_variance_actual, :target_variance_predicted, :sum_squared_error, :sample_correlation_coefficient ]
  
  CROSS_VAL_PROPS = [:dataset_uri, :num_folds, :stratified, :random_seed]
  CROSS_VAL_PROPS_REDUNDANT = [:crossvalidation_uri, :algorithm_uri, :created_at] + CROSS_VAL_PROPS 
  
  ALL_PROPS = VAL_PROPS + VAL_CV_PROPS + VAL_CLASS_PROPS_EXTENDED + VAL_REGR_PROPS + CROSS_VAL_PROPS

  VAL_MERGE_GENERAL = VAL_PROPS_GENERAL + VAL_CV_PROPS + [:classification_statistics, :regression_statistics] + CROSS_VAL_PROPS
  VAL_MERGE_SUM = VAL_PROPS_SUM + VAL_CLASS_PROPS_SINGLE_SUM + VAL_CLASS_PROPS_PER_CLASS_SUM
  VAL_MERGE_AVG = VAL_PROPS_AVG + VAL_CLASS_PROPS_SINGLE_AVG + VAL_CLASS_PROPS_PER_CLASS_AVG + VAL_REGR_PROPS
 
  class Validation < ActiveRecord::Base
    serialize :classification_statistics
    serialize :regression_statistics
  end
  
  class Crossvalidation < ActiveRecord::Base
  end
end
