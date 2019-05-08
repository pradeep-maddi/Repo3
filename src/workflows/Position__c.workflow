<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Email_New_Position_Alert</fullName>
        <description>Email New Position Alert</description>
        <protected>false</protected>
        <recipients>
            <recipient>MarketingTeam</recipient>
            <type>roleSubordinates</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>unfiled$public/Recruiting_App_New_Position_Alert</template>
    </alerts>
</Workflow>
