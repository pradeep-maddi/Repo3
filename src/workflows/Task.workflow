<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <rules>
        <fullName>Due_Date_Approaching</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Task.OwnerId</field>
            <operation>notEqual</operation>
            <value>null</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <offsetFromField>Task.ActivityDate</offsetFromField>
            <timeLength>-2</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
</Workflow>
