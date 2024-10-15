<?php

class LimeSuveyStatusWebhookPlugin extends PluginBase
	{
		protected $storage = 'DbStorage';
		static protected $description = 'A simple Webhook for LimeSurvey';
		static protected $name = 'LimeSuveyStatusWebhookPlugin';

        public function init() {
            // Hook into events triggered when a survey is completed and when a survey is initialized (before the first page is loaded)
            $this->subscribe('afterSurveyComplete'); // This event will be triggered when a respondent completed the survey
            $this->subscribe('beforeSurveyPage');  // This event will be triggered when a respondent initializes the survey
        }

		protected $settings = [
            'sWebhookUrl' => [
                'type' => 'string',
                'label' => 'Webhook URL',
                'default' => '',
                'help' => 'The URL to call when a survey is completed or initialized.',
            ],
            'sBug' => [
                'type' => 'boolean',
                'label' => 'Enable Debug Mode',
                'default' => false,
                'help' => 'Enable debugging to output the webhook call details.',
            ],
        ];


    public function beforeSurveyPage()
    {
        $event = $this->getEvent();
        error_log("survey_initialized");
        $this->triggerWebhook($event, 'survey_initialized');
    }

    public function afterSurveyComplete()
    {
        $event = $this->getEvent();
        error_log("survey_completed");
        $this->triggerWebhook($event, 'survey_completed');
    }

    /**
     * Function to fetch response data from the survey_* table
     * @param int $surveyId
     * @param int $responseId
     * @return array|null
     */
    protected function getResponseData($surveyId, $responseId)
    {
        // LimeSurvey stores responses in a table named "survey_{surveyId}"
        $tableName = '{{survey_' . intval($surveyId) . '}}';

        // Fetch the response data by querying the appropriate table
        $response = Yii::app()->db->createCommand()
            ->select('*')
            ->from($tableName)
            ->where('id = :responseId', [':responseId' => $responseId])
            ->queryRow();

        return $response ? $response : null;
    }

    protected function triggerWebhook(PluginEvent $event, $eventType)
    {
        error_log(json_encode($event));
        
        $surveyId = $event->get('surveyId');
        
        // Get token from the URL manually
        $token = Yii::app()->request->getParam('token', null);

        if($token == null) {
            $token = $event->get('token'); // Attempt to get from event object
        }

        // Try to fetch the current or default language
        $surveyInfo = Survey::model()->findByPk($surveyId);
        $lang = null !== $event->get('lang') ? $event->get('lang') : $surveyInfo->language; // Fallback to default language

        // Attempt to retrieve a survey group if applicable (you may need custom logic here)
        $surveyGroup = $event->get('surveyGroup'); // Get survey group if applicable

        $payload = [
            'event' => $eventType,
            'surveyId' => $surveyId,
            'token' => $token,
            'lang' => $lang,
            'surveyGroup' => $surveyGroup,
        ];
        
        // Include response data only for completion
        if ($eventType === 'survey_completed') {
            $payload['responseId'] = $event->get('responseId');
            // Fetch response data manually from the survey table
            $payload['responseData'] = $this->getResponseData($surveyId, $payload['responseId']);
        }
        
        error_log(json_encode($payload));

        $webhookUrl = $this->get('sWebhookUrl',  null, null, '');
        error_log($webhookUrl);
        
        // Validate webhook URL
        if (filter_var($webhookUrl, FILTER_VALIDATE_URL) === false) {
            error_log('Invalid webhook URL: ' . $webhookUrl);
            return; // Exit if the URL is not valid
        }

        if($token !== null) {
            $time_start = microtime(true);
            error_log('Sending message ' . json_encode($payload));
            $this->debug($webhookUrl, $payload, $time_start, null);
            $response = $this->sendWebhook($webhookUrl, $payload);
            $this->debug($webhookUrl, $payload, $time_start, $response);
        }
    }


    /**
     * Function to send the webhook request
     * @param string $url
     * @param array $data
     */
    protected function sendWebhook($url, $data)
    {
        if (empty($url)) {
            return; // No URL defined
        }

        // Initialize cURL session
        $ch = curl_init($url);

        // Set cURL options
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-Type: application/json']);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));

        // Execute the request
        $response = curl_exec($ch);

        // Handle errors (optional)
        if (curl_errno($ch)) {
            error_log('Webhook call failed: ' . curl_error($ch));
        }

        // Close cURL session
        curl_close($ch);

        return $response;
    }

    /**
     * Private function to debug webhook call details
     * @param string $url
     * @param array $parameters
     * @param float $time_start
     * @param mixed $response
     */
    private function debug($url, $parameters, $time_start, $response)
    {
        // Check if the 'sBug' setting is enabled
        if ($this->get('sBug', null, null, false)) {
            // Build HTML for debugging output
            $html = '<pre><br><br>----------------------------- DEBUG ----------------------------- <br><br>';
            $html .= 'Parameters: <br>' . print_r($parameters, true);
            $html .= "<br><br> ----------------------------- <br><br>";
            $html .= 'Hook sent to: ' . print_r($url, true) . '<br>';
            $html .= 'Total execution time in seconds: ' . (microtime(true) - $time_start) . '<br>';
            $html .= 'Response: ' . print_r($response, true) . '<br>';
            $html .= '</pre>';
            // Get the current event and append the debug HTML to the content
            error_log($logMessage);
        }
    }
}
