%== Aurora Solar Data Processing ==%
%== Jaehyun Lee 1/22/2018 ==%

% References to scripts to create data tables from excel sheets
CSIDataTableGenerate;
ZipcodesDataGenerate;

% Sorts out data to just solar installations that are completed and gets
% rid of NaN entries
CSIData = CSIData(ismember(CSIData.CurrentIncentiveApplicationStatus,{'Completed'}),:);
CSIData = CSIData(~any(ismissing(CSIData),2),:);

% Creates array with zipcode, number of installed solar panels, average
% nameplate rating
dataNew = [];
zips = [];
j = 0;
for i = 1:height(CSIData)
    if ~ismember(CSIData.HostCustomerPhysicalZipCode(i),zips)
        j = j + 1;
        zips = [zips CSIData.HostCustomerPhysicalZipCode(i)];
        k = find(CSIData.HostCustomerPhysicalZipCode(i)==CSIData.HostCustomerPhysicalZipCode(:));
        nameplate_zip = [];
        for a = 1:size(k)
            ind = k(a);
            nameplate_zip = [nameplate_zip CSIData.NameplateRating(ind)];
        end
        numUnits = numel(nameplate_zip);
        avg = sum(nameplate_zip)./numUnits;
        dataNew = [dataNew; CSIData.HostCustomerPhysicalZipCode(i),numUnits,avg];
    end
end
% Creates array with zipcode, average house value, average income per
% household
dataNew1 = [];
for b = 1:length(dataNew)
    zip = dataNew(b,1);
    index = find(zip==ZipcodesData.Zipcodes(:));
    if ~isempty(index)
        hVal = ZipcodesData.AvgHouseValue(index);
        iVal = ZipcodesData.IncomePerHousehold(index);
        dataNew1 = [dataNew1; zip,hVal,iVal]; 
    end
end
% Some zipcodes didn't have corresponding data in both sheets so this step
% eliminated the rows of zipcodes that had this issue (i.e. 92807)
dataNew = dataNew(ismember(dataNew(:,1),dataNew1(:,1)),:);
% Yields the final data table with the information as requested
dataFinal = [dataNew(:,1) dataNew(:,3) dataNew1(:,2) dataNew1(:,3) dataNew(:,2)];
T = array2table(dataFinal,'VariableNames',{'Zipcode','Avg_Nameplate_Rating','Avg_House_Value','Income_per_Household','completed_solar_installations'});
T.Properties.VariableUnits = {'' 'kW' '$' '$' ''};
xlswrite('LeeJaehyun_DataFinal.xlsx',dataFinal);
