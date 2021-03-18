function [outputArg1,outputArg2] = CS170_Search_Project(inputArg1,inputArg2)

% Prompt user for algorithm and dataset selection
% Datasets are provided by Dr. Eamonn Keogh.
fprintf("Welcome to Nathaniel Fey's Feature Search!\n")
userPrompt = 'Press 1 for forward selection, 2 for backwards elimination.\n';
user_choice = input(userPrompt);

if user_choice == 1
    dataPrompt = 'Press 1 for small dataset, 2 for large dataset.\n';
    user_data_choice = input(dataPrompt);
    if user_data_choice == 1
        fprintf('Running forward selection on small dataset\n')
        data = load('CS170_SMALLtestdata__73.txt');
        forward_selection(data)
    elseif user_data_choice == 2
        fprintf('Running forward selection on large dataset\n')
        data = load('CS170_largetestdata__49.txt');
        forward_selection(data)
    else
        fprintf("Invalid input \n")
    end
    
elseif user_choice == 2
    dataPrompt = 'Press 1 for small dataset, 2 for large dataset\n';
     user_data_choice = input(dataPrompt);
    if user_data_choice == 1
        fprintf('Running backwards elimination on small dataset\n')
        data = load('CS170_SMALLtestdata__73.txt');
        backwards_elimination(data)
    elseif user_data_choice == 2
        fprintf('Running backwards elimination on large dataset\n')
        data = load('CS170_largetestdata__49.txt');
        backwards_elimination(data)
    else
        fprintf('Invalid input \n')
    end
else
    fprintf('Invalid input \n')
end % end of user input

end % end of function

% Feature Search Function is guide code provided by Dr. Eamonn Keogh
% This helped create the Forward Selection and Backwards Eliminations 
% functions.
function feature_search(data) % function
current_set_of_features = []; % initialize empty set

for i = 1 :size(data,2)-1 %for loop goes through the data size
    disp(['On the ',num2str(i),'th level of the search tree']) 
    feature_to_add_at_this_level = []; % feature to add at our current level(picked)
    best_so_far_accuracy = 0; % accuracy, which is the more accurate feature?
    
    for k = 1 : size(data,2)-1 % check current set of features loop
        if isempty(intersect(current_set_of_features,k)) % only consider adding, if not added already
            disp(['Considering adding the ', num2str(k),' feature']) % 
            accuracy = leave_one_out_cross_validation(data,current_set_of_features,k+1); %
            if accuracy > best_so_far_accuracy % accuracy check
                best_so_far_accuracy = accuracy; % if the accuracy is better, add it
                feature_to_add_at_this_level = k; % the feature to add
            end
        end
    end
    current_set_of_features(i) = feature_to_add_at_this_level; % add the feature to set of features
    disp(['On level ',num2str(i), ' I added feature ',num2str(feature_to_add_at_this_level)])
end

end

% Leave One Out Cross Validation Function
% This function is provided by Dr. Eamonn Keogh. 
% Additions made were the features to ignore, data_size, and removal of
% features in data text file
function accuracy = leave_one_out_cross_validation(data,current_set,feature_to_add) %data,current_set,feature_to_add
    number_correctly_classified = 0;
    features_to_ignore = []; % holds what features to ignore
    current_set(end+1) = feature_to_add; % append feature to add to current set
    data_size = []; % gives each number of features in the current dataset
    
    % For loop below gets the total number of features in the dataset
    
    for j = 1:size(data,2)-1 % get the number of columns (features)
        data_size = [data_size,j]; % append the numbers into data_size, from user 'Image Analyst' on MatLab Answers
    end% % end of for loop
    
    features_to_ignore = setdiff(data_size,current_set); % ignore features not in the current set
    
    for i = 1: size(data,1) % begin scanning through the dataset
        object_to_classify = data(i,2:end); % look at what we need to classify (features)
        label_object_to_classify = data(i,1);% label the object 
         
         % Below we set the feature columns to 0. This ignores the
         % feature(s) in the data to get a better accuracy
        for m = 1 : size(features_to_ignore,1) % iterate thru features to ignore
             feature = features_to_ignore(m); % feature we will ignore
             data(:,feature) = 0; % set the feature's column to 0, from Bhaskar R
        end % end of setting columns to 0
        
        nearest_neighbor_distance = inf;
        nearest_neighbor_location = inf;
        for k = 1: size(data,1)
            if k ~= i
               
                distance = sqrt(sum((object_to_classify - data(k,2:end)).^2)); % Euclidean Distance calculation
                if distance < nearest_neighbor_distance
                    nearest_neighbor_distance = distance; % set nearest neighbor distance 
                    nearest_neighbor_location = k; % set the location of nearest neighbor
                    nearest_neighbor_label = data(nearest_neighbor_location,1); % label
                end
            end
        end
        % if we classify the feature correctly to its class, increment the
        % correct number of features classified.
        if label_object_to_classify == nearest_neighbor_label
            number_correctly_classified = number_correctly_classified+1;
            
        end
    end
  
    accuracy = number_correctly_classified / size(data,1); % return the accuracy
    
end

%%%%%%%%%%%% Backwards Elimination %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Most of the code is provided by Dr. Eamonn Keogh. Some modifications were
% made to the code such as getting the best features and its accuracy.
function backwards_elimination(data)
current_set_of_features = []; % initialize empty set for features
best_accuracy_overall = 0; % for the features with best accuracy overall other features
best_set_of_features = []; % current best set of features associated with best accuracy overall

for i = 1 :size(data,2)-1 %for loop goes through the data size
   % disp(['On the ',num2str(i),'th level of the search tree']) 
    feature_to_remove_at_this_level = []; % feature to remove at our current level(picked)
    best_so_far_accuracy = 0; % accuracy, which is the more accurate feature?
    
    for k = 1 : size(data,2)-1 % check current set of features loop
        if isempty(intersect(current_set_of_features,k)) % only consider adding, if not added already
            disp(['Considering removing the ', num2str(k),' feature']) % 
            accuracy = leave_one_out_cross_validation(data,current_set_of_features,k+1); %
            
            if accuracy > best_so_far_accuracy % accuracy check
                best_so_far_accuracy = accuracy; % if the accuracy is better, add it
                feature_to_remove_at_this_level = k; % the feature to add
            end % end of accuracy check
        end % end of adding feature
    end % end of checking  current set of features loop
    current_set_of_features(i) = feature_to_remove_at_this_level; % remove the feature to set of features
    disp(['On level ',num2str(i), ' I removed feature ',num2str(feature_to_remove_at_this_level)])
    disp(['Accuracy with current set ' num2str(accuracy)])
    disp(['Current removed features ', num2str(current_set_of_features)])
    if best_so_far_accuracy > best_accuracy_overall
        best_accuracy_overall = best_so_far_accuracy;
        best_set_of_features = current_set_of_features;
    end
       disp(['Best features to use ' num2str(best_set_of_features)])
       disp(['Best accuracy ', num2str(best_accuracy_overall)])
end


end



%%%%%%%%%%%%%%%% Forward Selection %%%%%%%%%%%%%%%%%%%%%%%%%%%
% Most of the code is provided by Dr. Eamonn Keogh. Some modifications were
% made to the code such as getting the best features and its accuracy.
function forward_selection(data)

current_set_of_features = []; % initialize empty set for features
best_accuracy_overall = 0; % for the features with best accuracy overall other features
best_set_of_features = []; % current best set of features associated with best accuracy overall
for i = 1 :size(data,2)-1 %for loop goes through the data size
   % disp(['On the ',num2str(i),'th level of the search tree']) 
    feature_to_add_at_this_level = []; % feature to add at our current level(picked)
    best_so_far_accuracy = 0; % accuracy, which is the more accurate feature?
    
    for k = 1 : size(data,2)-1 % check current set of features loop
        if isempty(intersect(current_set_of_features,k)) % only consider adding, if not added already
            disp(['Considering adding the ', num2str(k),' feature']) % 
            accuracy = leave_one_out_cross_validation(data,current_set_of_features,k+1); % get accuracy
            
            if accuracy > best_so_far_accuracy % accuracy check
                best_so_far_accuracy = accuracy; % if the accuracy is better, add it
                feature_to_add_at_this_level = k; % the feature to add
           
            end % end of accuracy check
        end % end of adding feature
    end % end of checking  current set of features loop
    current_set_of_features(i) = feature_to_add_at_this_level; % add the feature to set of features
    disp(['On level ',num2str(i), ' I added feature ',num2str(feature_to_add_at_this_level)])
    disp(['Accuracy with current set ' num2str(accuracy)])
    disp(['Current set ', num2str(current_set_of_features)])
    % check for the best accuracy and best features found during the scanning 
    if best_so_far_accuracy > best_accuracy_overall % check for overall accuracy
        best_accuracy_overall = best_so_far_accuracy; % best accuracy is noted
        best_set_of_features = current_set_of_features; % best set of features associated with best accuracy
    end
       disp(['Best features to use ' num2str(best_set_of_features)]) 
       disp(['Best accuracy ', num2str(best_accuracy_overall)])
end
%accuracy
end
