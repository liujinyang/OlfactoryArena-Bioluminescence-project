<?xml version='1.0' encoding='UTF-8'?>
<Project Type="Project" LVVersion="17008000">
	<Item Name="マイ コンピュータ" Type="My Computer">
		<Property Name="NI.SortType" Type="Int">3</Property>
		<Property Name="server.app.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.control.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="server.tcp.enabled" Type="Bool">false</Property>
		<Property Name="server.tcp.port" Type="Int">0</Property>
		<Property Name="server.tcp.serviceName" Type="Str">マイ コンピュータ/VIサーバ</Property>
		<Property Name="server.tcp.serviceName.default" Type="Str">マイ コンピュータ/VIサーバ</Property>
		<Property Name="server.vi.callsEnabled" Type="Bool">true</Property>
		<Property Name="server.vi.propertiesEnabled" Type="Bool">true</Property>
		<Property Name="specify.custom.address" Type="Bool">false</Property>
		<Item Name="Main_C8855-01.vi" Type="VI" URL="../Main_C8855-01.vi"/>
		<Item Name="C8855-01_Open.vi" Type="VI" URL="../C8855-01_Open.vi"/>
		<Item Name="C8855-01_Close.vi" Type="VI" URL="../C8855-01_Close.vi"/>
		<Item Name="C8855-01_ReadData.vi" Type="VI" URL="../C8855-01_ReadData.vi"/>
		<Item Name="C8855-01_InitCall.vi" Type="VI" URL="../C8855-01_InitCall.vi"/>
		<Item Name="C8855-01_CalcuP.vi" Type="VI" URL="../C8855-01_CalcuP.vi"/>
		<Item Name="C8855-01_InitWrite.vi" Type="VI" URL="../C8855-01_InitWrite.vi"/>
		<Item Name="C8855-01_CaseErase.vi" Type="VI" URL="../C8855-01_CaseErase.vi"/>
		<Item Name="C8855-01_CaseSelect.vi" Type="VI" URL="../C8855-01_CaseSelect.vi"/>
		<Item Name="C8855-01_ReadLinesFromFile.vi" Type="VI" URL="../C8855-01_ReadLinesFromFile.vi"/>
		<Item Name="C8855-01_ReadFromSpreadsheetFile.vi" Type="VI" URL="../C8855-01_ReadFromSpreadsheetFile.vi"/>
		<Item Name="C8855-01_WriteToSpreadsheetFile.vi" Type="VI" URL="../C8855-01_WriteToSpreadsheetFile.vi"/>
		<Item Name="C8855-01_OpenCreateReplaceFile.vi" Type="VI" URL="../C8855-01_OpenCreateReplaceFile.vi"/>
		<Item Name="C8855-01_MakingGate.vi" Type="VI" URL="../C8855-01_MakingGate.vi"/>
		<Item Name="C8855-01.rtm" Type="Document" URL="../C8855-01.rtm"/>
		<Item Name="C8855-01api.dll" Type="Document" URL="../C8855-01api.dll"/>
		<Item Name="C8855_MainD.ctl" Type="VI" URL="../C8855_MainD.ctl"/>
		<Item Name="Initdata.hpk" Type="Document" URL="../Initdata.hpk"/>
		<Item Name="C8855-01_NumForming.vi" Type="VI" URL="../C8855-01_NumForming.vi"/>
		<Item Name="依存性" Type="Dependencies">
			<Item Name="vi.lib" Type="Folder">
				<Item Name="Open File+.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Open File+.vi"/>
				<Item Name="Read File+ (string).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Read File+ (string).vi"/>
				<Item Name="compatReadText.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/compatReadText.vi"/>
				<Item Name="Close File+.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Close File+.vi"/>
				<Item Name="Find First Error.vi" Type="VI" URL="/&lt;vilib&gt;/Utility/error.llb/Find First Error.vi"/>
				<Item Name="compatFileDialog.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/compatFileDialog.vi"/>
				<Item Name="compatCalcOffset.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/compatCalcOffset.vi"/>
				<Item Name="Write File+ (string).vi" Type="VI" URL="/&lt;vilib&gt;/Utility/file.llb/Write File+ (string).vi"/>
				<Item Name="compatWriteText.vi" Type="VI" URL="/&lt;vilib&gt;/_oldvers/_oldvers.llb/compatWriteText.vi"/>
				<Item Name="Beep.vi" Type="VI" URL="/&lt;vilib&gt;/Platform/system.llb/Beep.vi"/>
			</Item>
		</Item>
		<Item Name="ビルド仕様" Type="Build">
			<Item Name="CountingUnitC8855-01" Type="EXE">
				<Property Name="App_INI_aliasGUID" Type="Str">{1D75CD3E-83D1-4EAB-B83C-EBD22CF0E098}</Property>
				<Property Name="App_INI_GUID" Type="Str">{88039382-44BA-498D-A250-2DD0F2E12155}</Property>
				<Property Name="App_serverConfig.httpPort" Type="Int">8002</Property>
				<Property Name="Bld_buildCacheID" Type="Str">{C5BA1FF9-E52C-4091-BE25-55BEF73455AD}</Property>
				<Property Name="Bld_buildSpecDescription" Type="Str">2009/09/10&gt;
装置接続しない状態でデータ呼び出し時に無限Loopになるのを回避。具体的処置としてOpen.viでの戻り値を確定した。
2009/11/25&gt;
旧バージョンのdll（C8855api.dll）を参照していたので変更
2012/02/06&gt;
LibUSBドライバに対応したDLL変更版
2012/10/2&gt;
ExtTrig 対応
2019/10/1&gt;
dll変更(libusb-1.0ベース）
2020/3/31&gt;
ExtTrig検出エッジ方向選択機能追加（dllも変更）
2024/3/27
Ver3.3.1(Minor update): sec-&gt;s, cps-&gt;s^-1</Property>
				<Property Name="Bld_buildSpecName" Type="Str">CountingUnitC8855-01</Property>
				<Property Name="Bld_excludeLibraryItems" Type="Bool">true</Property>
				<Property Name="Bld_excludePolymorphicVIs" Type="Bool">true</Property>
				<Property Name="Bld_localDestDir" Type="Path">//den0/電応システム部/電応システム/部内資料/13部門/33412/■ C8855-01/□付属ＣＤ/C8855-01 Ver3.4[最新]/Sample/EXE_x86</Property>
				<Property Name="Bld_modifyLibraryFile" Type="Bool">true</Property>
				<Property Name="Bld_previewCacheID" Type="Str">{32E728DC-168D-4BAD-9D10-F6671504DE1D}</Property>
				<Property Name="Bld_version.major" Type="Int">3</Property>
				<Property Name="Bld_version.minor" Type="Int">3</Property>
				<Property Name="Bld_version.patch" Type="Int">1</Property>
				<Property Name="Destination[0].destName" Type="Str">C8855-01.exe</Property>
				<Property Name="Destination[0].path" Type="Path">//den0/電応システム部/電応システム/部内資料/13部門/33412/■ C8855-01/□付属ＣＤ/C8855-01 Ver3.4[最新]/Sample/EXE_x86/C8855-01.exe</Property>
				<Property Name="Destination[0].path.type" Type="Str">&lt;none&gt;</Property>
				<Property Name="Destination[0].type" Type="Str">App</Property>
				<Property Name="Destination[1].destName" Type="Str">サポートディレクトリ</Property>
				<Property Name="Destination[1].path" Type="Path">//den0/電応システム部/電応システム/部内資料/13部門/33412/■ C8855-01/□付属ＣＤ/C8855-01 Ver3.4[最新]/Sample/EXE_x86</Property>
				<Property Name="Destination[1].path.type" Type="Str">&lt;none&gt;</Property>
				<Property Name="DestinationCount" Type="Int">2</Property>
				<Property Name="Source[0].itemID" Type="Str">{7C8EAE65-E93C-4DC7-A97E-797A15A92AB8}</Property>
				<Property Name="Source[0].type" Type="Str">Container</Property>
				<Property Name="Source[1].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[1].itemID" Type="Ref">/マイ コンピュータ/Main_C8855-01.vi</Property>
				<Property Name="Source[1].sourceInclusion" Type="Str">TopLevel</Property>
				<Property Name="Source[1].type" Type="Str">VI</Property>
				<Property Name="Source[2].destinationIndex" Type="Int">0</Property>
				<Property Name="Source[2].itemID" Type="Ref">/マイ コンピュータ/Initdata.hpk</Property>
				<Property Name="Source[2].sourceInclusion" Type="Str">Include</Property>
				<Property Name="SourceCount" Type="Int">3</Property>
				<Property Name="TgtF_companyName" Type="Str">Hamamatsu</Property>
				<Property Name="TgtF_fileDescription" Type="Str">CountingUnitC8855-01</Property>
				<Property Name="TgtF_internalName" Type="Str">CountingUnitC8855-01</Property>
				<Property Name="TgtF_legalCopyright" Type="Str">著作権 2020 Hamamatsu</Property>
				<Property Name="TgtF_productName" Type="Str">CountingUnitC8855-01</Property>
				<Property Name="TgtF_targetfileGUID" Type="Str">{F0E1BBD1-900B-4916-9CF8-1F9B0837E031}</Property>
				<Property Name="TgtF_targetfileName" Type="Str">C8855-01.exe</Property>
			</Item>
			<Item Name="C8855-01 CountingUnit" Type="Installer">
				<Property Name="Destination[0].name" Type="Str">CountingUnitC8855-01</Property>
				<Property Name="Destination[0].parent" Type="Str">{3912416A-D2E5-411B-AFEE-B63654D690C0}</Property>
				<Property Name="Destination[0].tag" Type="Str">{617DDD42-1768-46FF-BAEE-8469400BA24D}</Property>
				<Property Name="Destination[0].type" Type="Str">userFolder</Property>
				<Property Name="Destination[0].unlock" Type="Bool">true</Property>
				<Property Name="DestinationCount" Type="Int">1</Property>
				<Property Name="DistPart[0].flavorID" Type="Str">DefaultFull</Property>
				<Property Name="DistPart[0].productID" Type="Str">{1A4448CF-1F95-420D-ABAD-2AB572A8A341}</Property>
				<Property Name="DistPart[0].productName" Type="Str">NI LabVIEW Runtime 2017 SP1 f3</Property>
				<Property Name="DistPart[0].SoftDep[0].exclude" Type="Bool">false</Property>
				<Property Name="DistPart[0].SoftDep[0].productName" Type="Str">NI LabVIEW Runtime 2017 SP1 Non-English Support.</Property>
				<Property Name="DistPart[0].SoftDep[0].upgradeCode" Type="Str">{182AE811-85B6-4238-B67E-F19497CC186B}</Property>
				<Property Name="DistPart[0].SoftDep[1].exclude" Type="Bool">false</Property>
				<Property Name="DistPart[0].SoftDep[1].productName" Type="Str">NI ActiveX Container</Property>
				<Property Name="DistPart[0].SoftDep[1].upgradeCode" Type="Str">{1038A887-23E1-4289-B0BD-0C4B83C6BA21}</Property>
				<Property Name="DistPart[0].SoftDep[10].exclude" Type="Bool">false</Property>
				<Property Name="DistPart[0].SoftDep[10].productName" Type="Str">NI mDNS Responder 17.0</Property>
				<Property Name="DistPart[0].SoftDep[10].upgradeCode" Type="Str">{9607874B-4BB3-42CB-B450-A2F5EF60BA3B}</Property>
				<Property Name="DistPart[0].SoftDep[11].exclude" Type="Bool">false</Property>
				<Property Name="DistPart[0].SoftDep[11].productName" Type="Str">NI Deployment Framework 2018</Property>
				<Property Name="DistPart[0].SoftDep[11].upgradeCode" Type="Str">{838942E4-B73C-492E-81A3-AA1E291FD0DC}</Property>
				<Property Name="DistPart[0].SoftDep[12].exclude" Type="Bool">false</Property>
				<Property Name="DistPart[0].SoftDep[12].productName" Type="Str">NI Error Reporting 2018</Property>
				<Property Name="DistPart[0].SoftDep[12].upgradeCode" Type="Str">{42E818C6-2B08-4DE7-BD91-B0FD704C119A}</Property>
				<Property Name="DistPart[0].SoftDep[2].exclude" Type="Bool">false</Property>
				<Property Name="DistPart[0].SoftDep[2].productName" Type="Str">Math Kernel Libraries</Property>
				<Property Name="DistPart[0].SoftDep[2].upgradeCode" Type="Str">{699C1AC5-2CF2-4745-9674-B19536EBA8A3}</Property>
				<Property Name="DistPart[0].SoftDep[3].exclude" Type="Bool">false</Property>
				<Property Name="DistPart[0].SoftDep[3].productName" Type="Str">NI Logos 18.0</Property>
				<Property Name="DistPart[0].SoftDep[3].upgradeCode" Type="Str">{5E4A4CE3-4D06-11D4-8B22-006008C16337}</Property>
				<Property Name="DistPart[0].SoftDep[4].exclude" Type="Bool">false</Property>
				<Property Name="DistPart[0].SoftDep[4].productName" Type="Str">NI TDM Streaming 18.0</Property>
				<Property Name="DistPart[0].SoftDep[4].upgradeCode" Type="Str">{4CD11BE6-6BB7-4082-8A27-C13771BC309B}</Property>
				<Property Name="DistPart[0].SoftDep[5].exclude" Type="Bool">false</Property>
				<Property Name="DistPart[0].SoftDep[5].productName" Type="Str">NI LabVIEW Web Server 2017</Property>
				<Property Name="DistPart[0].SoftDep[5].upgradeCode" Type="Str">{0960380B-EA86-4E0C-8B57-14CD8CCF2C15}</Property>
				<Property Name="DistPart[0].SoftDep[6].exclude" Type="Bool">false</Property>
				<Property Name="DistPart[0].SoftDep[6].productName" Type="Str">NI LabVIEW Real-Time NBFifo 2017</Property>
				<Property Name="DistPart[0].SoftDep[6].upgradeCode" Type="Str">{4F261250-2C38-488D-A9EC-9D1EFCC24D4B}</Property>
				<Property Name="DistPart[0].SoftDep[7].exclude" Type="Bool">false</Property>
				<Property Name="DistPart[0].SoftDep[7].productName" Type="Str">NI VC2008MSMs</Property>
				<Property Name="DistPart[0].SoftDep[7].upgradeCode" Type="Str">{FDA3F8BB-BAA9-45D7-8DC7-22E1F5C76315}</Property>
				<Property Name="DistPart[0].SoftDep[8].exclude" Type="Bool">false</Property>
				<Property Name="DistPart[0].SoftDep[8].productName" Type="Str">NI VC2010MSMs</Property>
				<Property Name="DistPart[0].SoftDep[8].upgradeCode" Type="Str">{EFBA6F9E-F934-4BD7-AC51-60CCA480489C}</Property>
				<Property Name="DistPart[0].SoftDep[9].exclude" Type="Bool">false</Property>
				<Property Name="DistPart[0].SoftDep[9].productName" Type="Str">NI VC2015 Runtime</Property>
				<Property Name="DistPart[0].SoftDep[9].upgradeCode" Type="Str">{D42E7BAE-6589-4570-B6A3-3E28889392E7}</Property>
				<Property Name="DistPart[0].SoftDepCount" Type="Int">13</Property>
				<Property Name="DistPart[0].upgradeCode" Type="Str">{620DBAE1-B159-4204-8186-0813C8A6434C}</Property>
				<Property Name="DistPartCount" Type="Int">1</Property>
				<Property Name="INST_buildLocation" Type="Path">//den0/電応システム部/電応システム/部内資料/13部門/33412/■ C8855-01/□付属ＣＤ/C8855-01 Ver3.4[最新]/Sample/Installer_x86</Property>
				<Property Name="INST_buildSpecName" Type="Str">C8855-01 CountingUnit</Property>
				<Property Name="INST_defaultDir" Type="Str">{617DDD42-1768-46FF-BAEE-8469400BA24D}</Property>
				<Property Name="INST_productName" Type="Str">Counting Unit C8855-01</Property>
				<Property Name="INST_productVersion" Type="Str">3.3.1</Property>
				<Property Name="InstSpecBitness" Type="Str">32-bit</Property>
				<Property Name="InstSpecVersion" Type="Str">17018002</Property>
				<Property Name="MSI_arpCompany" Type="Str">Hamamatsu</Property>
				<Property Name="MSI_arpContact" Type="Str">静岡県磐田市下神増314-5</Property>
				<Property Name="MSI_arpPhone" Type="Str">0539-62-3151</Property>
				<Property Name="MSI_arpURL" Type="Str">http://www.Hamamatsu.com/</Property>
				<Property Name="MSI_distID" Type="Str">{BB8DF2C8-8C43-4895-A3FE-F9F5F763E0A7}</Property>
				<Property Name="MSI_osCheck" Type="Int">0</Property>
				<Property Name="MSI_upgradeCode" Type="Str">{ADAA1FCF-6C38-4A52-9FE5-545E0CD48191}</Property>
				<Property Name="RegDest[0].dirName" Type="Str">Software</Property>
				<Property Name="RegDest[0].dirTag" Type="Str">{DDFAFC8B-E728-4AC8-96DE-B920EBB97A86}</Property>
				<Property Name="RegDest[0].parentTag" Type="Str">2</Property>
				<Property Name="RegDestCount" Type="Int">1</Property>
				<Property Name="Source[0].dest" Type="Str">{617DDD42-1768-46FF-BAEE-8469400BA24D}</Property>
				<Property Name="Source[0].File[0].dest" Type="Str">{617DDD42-1768-46FF-BAEE-8469400BA24D}</Property>
				<Property Name="Source[0].File[0].name" Type="Str">C8855-01.exe</Property>
				<Property Name="Source[0].File[0].Shortcut[0].destIndex" Type="Int">0</Property>
				<Property Name="Source[0].File[0].Shortcut[0].name" Type="Str">C8855-01</Property>
				<Property Name="Source[0].File[0].Shortcut[0].subDir" Type="Str">Counting Unit C8855-01</Property>
				<Property Name="Source[0].File[0].ShortcutCount" Type="Int">1</Property>
				<Property Name="Source[0].File[0].tag" Type="Str">{F0E1BBD1-900B-4916-9CF8-1F9B0837E031}</Property>
				<Property Name="Source[0].FileCount" Type="Int">1</Property>
				<Property Name="Source[0].name" Type="Str">CountingUnitC8855-01</Property>
				<Property Name="Source[0].tag" Type="Ref">/マイ コンピュータ/ビルド仕様/CountingUnitC8855-01</Property>
				<Property Name="Source[0].type" Type="Str">EXE</Property>
				<Property Name="SourceCount" Type="Int">1</Property>
			</Item>
		</Item>
	</Item>
</Project>
