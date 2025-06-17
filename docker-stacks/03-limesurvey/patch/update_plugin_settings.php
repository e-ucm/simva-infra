    /**
    * RPC method: update_plugin_settings
    *
    * @param string $sSessionKey
    * @param string $sPluginName
    * @param int    $iSurveyId      Use 0 for global settings
    * @param array  $aSettings      key→value pairs
    * @return array                ['status'=>'OK'] or throws CHttpException(400, …)
    */
    public function update_plugin_settings($sSessionKey, $sPluginName, $iSurveyId, $aSettings)
    {
        // 1) Validate session & permissions
        if (!$this->_checkSessionKey($sSessionKey)) {
            return array('status' => 'Invalid session key');
        }

        // 2) Grab the plugin via the app component
        /** @var PluginManager $pm */
        $pm      = Yii::app()->pluginManager;
        $plugin = $pm->loadPlugin($pluginName);
        
        // 3) Persist your settings
        try {
            if ($iSurveyId) {
                // survey‐specific settings
                $plugin->setSurveySettings($sPluginName, $iSurveyId, $aSettings);
            } else {
                // global settings
                $plugin->setGlobalSettings($sPluginName, $aSettings);
            }
        } catch (Exception $e) {
            throw new CHttpException(500, "Could not save plugin settings: ".$e->getMessage());
        }


        // 4) Return success
        return ['status'=>'OK'];
    }