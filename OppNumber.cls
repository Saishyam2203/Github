/**
* @File Name     : OpportunityAutoNumberGeneratorHandler
* @Created BY    : Plative 
* @Date          : 17 Nov,2022
* @Description   : Handler for opportunityAutoNumberGenerator
*  Version         Developer     Date             Details
*  --------------------------------------------------------------------------------------------------------------------------------------------*
     1.1             Plative     1 Nov,2023     Opportunities Project Number generate,handling the duplications and 
                                                the auto numbers are incremented in a sequence.
* */
public class OpportunityAutoNumberGeneratorHandler {
    
    public static List<string> alphabets = new List<string>{'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z'};   
        
        public static void opportunitySeparator(List<Opportunity> listOfOpp){
            //List of New Original Opportunities Project Number - 000001-00-0
            List<Opportunity> listOfOriginalOpportunities = new List<Opportunity>();
            
            //Map of Original Opp and the List of Events Opportunity Project Number - 000001-01-0 
            Map<Id,List<Opportunity>> mapOfOppwithEventsChildOpportunityOpp = new Map<Id,List<Opportunity>>();
            
            //Map of Original Opp and the List of Addendum Opportunity Project Number - 000001-01-A
            Map<Id,List<Opportunity>> mapOfOppwithAmendmentOpp = new Map<Id,List<Opportunity>>();
            
            //Collect the Event and Addendum Opportunities to Update the Project Number. 
            For(Opportunity opp : listOfOpp){
                
                //Check if the Current opp is Event child Opp.
                If(opp.Orginal_Opportunity__c !=null && opp.Project_Types__c == 'Events'){
                    If(mapOfOppwithEventsChildOpportunityOpp.containsKey(opp.Orginal_Opportunity__c)){
                        mapOfOppwithEventsChildOpportunityOpp.get(opp.Orginal_Opportunity__c).add(opp);
                    }else{
                        mapOfOppwithEventsChildOpportunityOpp.put(opp.Orginal_Opportunity__c,new List<Opportunity>{opp});
                    }
                    //Check if the Current opp is Addendum child Opp.
                }else If(opp.Orginal_Opportunity__c !=null && opp.Project_Types__c == 'Addendum'){
                    If(mapOfOppwithAmendmentOpp .containsKey(opp.Orginal_Opportunity__c)){
                        mapOfOppwithAmendmentOpp .get(opp.Orginal_Opportunity__c).add(opp);
                    }else{
                        mapOfOppwithAmendmentOpp .put(opp.Orginal_Opportunity__c,new List<Opportunity>{opp});
                    }
                }
            }
            //Project Number generation for Event Opp
            If(mapOfOppwithEventsChildOpportunityOpp.size() > 0){
                childOppAutoNumberCreate(mapOfOppwithEventsChildOpportunityOpp);
            }
            //Project Number generation for Addendum Opp 
            If(mapOfOppwithAmendmentOpp .size() > 0){
                amendmentOppAutoNumberCreate(mapOfOppwithAmendmentOpp );
            }
        }
    // After Insert
    // Generate the Original Opportunity Project Number 000001-00-0
    // Auto Project Number is the standard auto number this logic add the suffix to this number
    public static void originalOpportunityAutoNumberCreate(List<Opportunity> listOfOriginalOpp){
        List<Opportunity> newProjectNumberOpp = new List<Opportunity>();
        List<Opportunity> autoIdOpp = [SELECT Id ,Orginal_Opportunity__c,Auto_Project_Number__c,Project_Number__c FROM Opportunity Where Orginal_Opportunity__c = null AND Project_Number__c = null AND Id In: listOfOriginalOpp ];
        For(Opportunity opp : autoIdOpp){
            If(opp.Orginal_Opportunity__c == null){
                opp.Project_Number__c = opp.Auto_Project_Number__c + '-00-0';
                newProjectNumberOpp.add(opp); 
            }
        }
        If(!newProjectNumberOpp.isempty()){
            Update newProjectNumberOpp;
        }
    }
    // Before Insert
    // Event Opportunity Project Number generate based on the count of event opportunity in the Original Opportunity 
    // Project Number 000001-01-0 
    public static void childOppAutoNumberCreate(Map<Id,List<Opportunity>> mapOfChildOpp){
        If(mapOfChildOpp.size() > 0){
            //Collecting the Original Opportunity
            Map<Id, Opportunity> initailOppMapAutoNum = new Map<Id, Opportunity>([SELECT Id,Project_Number__c,Event_Number__c,Project_Types__c FROM Opportunity WHERE Id IN: mapOfChildOpp.KeySet()]);
            Integer counter = 1;
            map<Id,Integer> updateEventNumber = new map<Id, Integer>();
            Integer newEventNumber;
            List<Opportunity> newOppnumberUpdate = new List<Opportunity>(); 
            
            For(Id OriginalOppID : mapOfChildOpp.keySet()){
                For(Opportunity amendCurrentOpp : mapOfChildOpp.get(OriginalOppID)){
                    // Check the Original opportunity event Opp's count is greater than Zero and generate the Project number for Event Type
                    If(initailOppMapAutoNum.get(amendCurrentOpp.Orginal_Opportunity__c) != null && initailOppMapAutoNum.get(amendCurrentOpp.Orginal_Opportunity__c).Event_Number__c >0){
                        amendCurrentOpp.Project_Number__c = initailOppMapAutoNum.get(OriginalOppID).Project_Number__c.removeEnd('00-0')+String.valueOf(initailOppMapAutoNum.get(OriginalOppID).Event_Number__c + counter).leftPad(2, '0')+'-0';
                        newEventNumber = (Integer)initailOppMapAutoNum.get(OriginalOppID).Event_Number__c + counter;
                        counter ++;
                    }
                    // Check the First time Original opportunity event Opp's count and generate the Project number for Event Type
                    else{
                        amendCurrentOpp.Project_Number__c = initailOppMapAutoNum.get(OriginalOppID).Project_Number__c.removeEnd('00-0')+String.valueOf(counter).leftPad(2, '0')+'-0';
                        newEventNumber = counter;
                        counter ++;
                    }
                    //Collecting the Increment count for Event to update in Original opportunity
                    updateEventNumber.put(OriginalOppID,newEventNumber);
                }
            }
            //Update the Event Count in Original Opportunity
            If(updateEventNumber.Size()>0){
                For(Id OppParentId : initailOppMapAutoNum.keyset() ){
                    If(updateEventNumber.containskey(OppParentId)){
                        Opportunity OppParent = initailOppMapAutoNum.get(OppParentId);
                        OppParent.Event_Number__c = updateEventNumber.get(OppParentId);
                        newOppnumberUpdate.add(OppParent);
                    }
                }
                Update newOppnumberUpdate;
            }
        }
    }
    // Before Insert
    // Addendum Opportunity Project Number generate based on the count of addendum opportunity in the Original Opportunity 
    // Project Number 000001-01-A 
    public static void amendmentOppAutoNumberCreate(Map<Id,List<Opportunity>> mapOfOppwithAmendmentOpp){
        If(mapOfOppwithAmendmentOpp.size() > 0){
            Map<Id, Opportunity> initailOppMapAutoNum = new Map<Id, Opportunity>([SELECT Id,Project_Number__c,Project_Types__c,Addendum_Number__c  FROM Opportunity WHERE Id IN: mapOfOppwithAmendmentOpp.KeySet()]);
            Integer counter = 0;
            Integer UpdateCounter = 1;
            map<Id,Integer> updateAddendumNumber = new map<Id, Integer>();
            Integer newAddendumNumber;
            List<Opportunity> OppAddendumnumberUpdate = new List<Opportunity>();
            
            For(Id OriginalOppID : mapOfOppwithAmendmentOpp.keySet()){
                For(Opportunity amendCurrentOpp : mapOfOppwithAmendmentOpp.get(OriginalOppID)){
                    // Check the Original opportunity addendum Opp's count is greater than Zero and generate the Project number for addendum Type
                    If(initailOppMapAutoNum.get(OriginalOppID) != null && initailOppMapAutoNum.get(amendCurrentOpp.Orginal_Opportunity__c).Addendum_Number__c >0){
                        amendCurrentOpp.Project_Number__c = initailOppMapAutoNum.get(OriginalOppID).Project_Number__c.removeEnd('0')+alphabets[(Integer)initailOppMapAutoNum.get(OriginalOppID).Addendum_Number__c+counter];
                        newAddendumNumber = (Integer)initailOppMapAutoNum.get(OriginalOppID).Addendum_Number__c + UpdateCounter;
                        counter ++;
                    }
                    // Check the First time Original opportunity addendum Opp's count and generate the Project number for addendum Type
                    else{
                        amendCurrentOpp.Project_Number__c = initailOppMapAutoNum.get(OriginalOppID).Project_Number__c.removeEnd('0') +alphabets[counter];
                        newAddendumNumber = counter + UpdateCounter; 
                        counter ++;
                    }  
                }
                updateAddendumNumber.put(OriginalOppID,newAddendumNumber);
            }
            //Update the Addendum Count in Original Opportunity
            If(updateAddendumNumber.Size()>0){
                For(Id OppParentId : initailOppMapAutoNum.keyset() ){
                    If(updateAddendumNumber.containskey(OppParentId)){
                        Opportunity OppParent = initailOppMapAutoNum.get(OppParentId);
                        OppParent.Addendum_Number__c = updateAddendumNumber.get(OppParentId);
                        OppAddendumnumberUpdate.add(OppParent);
                    }
                }
                Update OppAddendumnumberUpdate;
            }
        }
    }
}