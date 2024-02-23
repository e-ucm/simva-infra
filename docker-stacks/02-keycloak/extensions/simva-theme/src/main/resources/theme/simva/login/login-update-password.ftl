<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true; section>
    <#if section = "header">
    <#elseif section = "form">
        <div class="kcform">
            <h1 id="kc-page-title">
                ${msg("updatePasswordTitle")}
            </h1>
            <form action="${url.loginAction}" method="post">
                <input type="email" id="username" name="username" value="${username}" autocomplete="email" readonly="readonly" style="display:none;"/>
                <input type="password" id="password" name="password" autocomplete="current-password" style="display:none;"/>

                <div class="${properties.kcFormGroupClass!}">
                    <div class="${properties.kcInputWrapperClass!}">
                    <input type="password" id="password-new" name="password-new" class="${properties.kcInputClass!}" pattern=".{8,}" autofocus autocomplete="new-password" required/>
                    </div>
                    <div class="${properties.kcLabelWrapperClass!}">
                    <label for="password-new">${msg("passwordNew")}</label>
                    </div>
                </div>

                <div class="${properties.kcFormGroupClass!}">
                    <div class="${properties.kcInputWrapperClass!}">
                        <input type="password" id="password-confirm" name="password-confirm" class="${properties.kcInputClass!}" autocomplete="new-password" required/>
                    </div>
                    <div class="${properties.kcLabelWrapperClass!}">
                        <label for="password-confirm">${msg("passwordConfirm")}</label>
                    </div>
                </div>

                <div class="${properties.kcFormButtonsClass!}">
                <input class="submit ${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" type="submit" value="${msg("passwordConfirm")}"/>
                </div>
            </form>
        </div>
    </#if>
</@layout.registrationLayout>
