<#import "template.ftl" as layout>
<@layout.registrationLayout; section>
    <#if section = "header">
       
    <#elseif section = "form">
        <h1 id="kc-page-title">
             ${msg("oauth2DeviceVerificationTitle")}
        </h1>
        <div id="kc-form" class="box-container para <#if realm.password && social.providers??>${properties.kcContentWrapperClass!}</#if>">
            <form id="kc-user-verify-device-user-code-form" class="${properties.kcFormClass!}" action="${url.oauth2DeviceVerificationAction}" method="post">
                <div class="${properties.kcFormGroupClass!}">
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="device-user-code" class="${properties.kcLabelClass!}">${msg("verifyOAuth2DeviceUserCode")}</label>
                    </div>

                    <div class="${properties.kcInputWrapperClass!}">
                        <input id="device-user-code" name="device_user_code" autocomplete="off" type="text" class="${properties.kcInputClass!}" autofocus />
                    </div>
                </div>

                <div class="${properties.kcFormGroupClass!}">
                    <div id="kc-form-options" class="${properties.kcFormOptionsClass!}">
                        <div class="${properties.kcFormOptionsWrapperClass!}">
                        </div>
                    </div>

                    <div id="kc-form-buttons" class="${properties.kcFormButtonsClass!}">
                        <div class="${properties.kcFormButtonsWrapperClass!}">
                            <input class="submit ${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("doSubmit")}"/>
                        </div>
                    </div>
                </div>
            </form>
        </div>
    </#if>
</@layout.registrationLayout>