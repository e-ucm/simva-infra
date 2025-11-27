    /*** RPC Routine to export a survey structure (LSS).
    *
    * @access public
    * @param string $sSessionKey Auth credentials
    * @param int $iSurveyID_org Id of the survey
    * @return string|array in case of success : Base64 encoded string of the .lss file. On failure array with error information.
    * */
    public function export_survey_structure ($sSessionKey, $iSurveyID_org)
    {
        $iSurveyID = (int) $iSurveyID_org;
        if (!$this->_checkSessionKey($sSessionKey)) {
            return array('status' => 'Invalid session key');
        }
        $aData['bFailed'] = false; // Put a var for continue
        if (!$iSurveyID) {
            $aData['sErrorMessage'] = "No survey ID has been provided. Cannot export survey";
            $aData['bFailed'] = true;
        } elseif (!Survey::model()->findByPk($iSurveyID)) {
            $aData['sErrorMessage'] = "Invalid survey ID";
            $aData['bFailed'] = true;
        } elseif (!Permission::model()->hasSurveyPermission($iSurveyID, 'surveycontent', 'export') && !Permission::model()->hasSurveyPermission($iSurveyID, 'surveycontent', 'export')) {
            $aData['sErrorMessage'] = "You don't have sufficient permissions.";
            $aData['bFailed'] = true;
        } else {
            $aExcludes = array();
            $aExcludes['dates'] = true;
            $btranslinksfields = true;
            Yii::app()->loadHelper('export');
            $exportsurveystructuredata = surveyGetXMLData($iSurveyID, $aExcludes);
            if ($exportsurveystructuredata) {
                $sResult = $exportsurveystructuredata;
            } else {
                $aData['bFailed'] = true;
            }
        }
        if ($aData['bFailed']) {
            return array('status' => 'Export failed', 'error'=> $aData['sErrorMessage']);
        } else {
            return base64_encode($sResult);
        }
    }