<cfcomponent displayname="GEO-Datas" hint="verschiedene Funktionen zur Erweiterung von ColdFusion">

<cffunction name="init" returntype="maxmind" access="remote" output="false" displayname="constructor" hint="stellt die initialen Werte zur Verfügung">
	<cfargument name="AccountID" type="string" required="true" displayname="LicenseKy" hint="Muss bei MaxMind beantragt werden">

	<cfset variables.instance = structNew() />
	<cfset variables.instance.AccountID = arguments.AccountID />
	<cfset variables.instance.AccountFields_Basic			= 'Country,Region,City,Latitude,Longitude,ErrorCode'>
	<cfset variables.instance.AccountFields_Advanced	= 'Country,Region,City,Postal,Latitude,Longitude,Metropolitan,Area,ISP,Organization,ErrorCode'>

	<cfreturn this />
</cffunction>

<cffunction name="list2Array" returntype="array" access="remote" output="false" displayname="liefert ein Array aufgrund einer CSV-Liste" hint="Inklusive Anfuerungszeichen bei Stringwerten">
	<cfargument name="myList" type="string" required="true" displayname="die CSV-Zeile" hint="In Anfuerungszeichen wenn zb ein Komma in einem Stringwert enthalten sein könnte" />

	<cfset var myArray		= ArrayNew(1) />
	<cfset var myElements	= arguments.myList.split(',',-1) />
	<cfset var myString		= "" />
	<cfset var doAppend		= false />
	<cfset var myField		= "">

	<cfloop from="1" to="#ArrayLen(myElements)#" index="myField">
		<cfif left(myElements[myField],1) EQ chr(34) OR doAppend>
			<cfset myString = listAppend(myString,myElements[myField]) />
			<cfset doAppend = true />

			<cfif right(myElements[myField],1) EQ chr(34)>
				<cfset ArrayAppend(myArray,removeChars(removeChars(myString,len(myString),2),1,1)) />
				<cfset myString = "" />
				<cfset doAppend = false />
			</cfif>

		<cfelseif NOT doAppend>
			<cfset ArrayAppend(myArray,myElements[myField]) />
		</cfif>
	</cfloop>

	<cfreturn myArray />
</cffunction>


<cffunction name="getGEOfromIP" returntype="struct" access="remote" output="false" displayname="liefert ein Struct aufgrund einer CSV-Liste" hint="um namentlich auf die Werte zugreifen zu koennen">
	<cfargument name="ClientIP" type="string" required="true" displayname="IP-Adresse" hint="welche ausgewertet werden soll" />
	<cfargument name="Advanced" type="boolean" required="false" default="false" displayname="Zusatzdaten" hint="ISP und Organisation auch anzeigen?" />

	<cfset var myArray		= arrayNew(1) />
	<cfset var myStruct		= structNew() />
	<cfset var myMMGEOs		= "" />
	<cfset var myMMFields	= iif(arguments.Advanced,de(variables.instance.AccountFields_Advanced),de(variables.instance.AccountFields_Basic)) />

	<cfhttp url="http://maxmind.com:8010/#iif(arguments.Advanced,de('f'),de('b'))#?l=#variables.instance.AccountID#&i=#arguments.ClientIP#" result="myMMGEOs">

	<cfset myArray = list2Array(myMMGEOs.fileContent) />
	<cfloop from="1" to="#ArrayLen(myArray)#" index="myField">
		<cfset myStruct[listGetAt(myMMFields,myField)] = myArray[myField] />
	</cfloop>

	<cfreturn myStruct />
</cffunction>

</cfcomponent>