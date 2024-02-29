<#import "template.ftl" as layout>
<@layout.registrationLayout displayInfo=true; section>
<#if section = "header">
<#elseif section = "form">
  <h1 id="kc-page-title">
    ${msg("emailForgotTitle")}
  </h1>
  ${msg("emailInstruction")}
  <div id="kc-form" class="box-container para <#if realm.password && social.providers??>${properties.kcContentWrapperClass!}</#if>">
    <div id="sign-in-section">
        <form id="kc-form-sign-in" class="${properties.kcFormClass!}" action="${url.loginAction}" method="post">
          <div class="${properties.kcInputWrapperClass!}">
              <#if auth?has_content && auth.showUsername()>
                  <input type="email" id="username" name="username" class="${properties.kcInputClass!}" autofocus value="${auth.attemptedUsername}" required/>
              <#else>
                  <input type="email" id="username" name="username" class="${properties.kcInputClass!}" autofocus required/>
              </#if>
          </div>
          <div class="${properties.kcLabelWrapperClass!}">
              <label for="username">${msg("email")}</label>
          </div>
            
          <div class="${properties.kcFormButtonsClass!}">
            <input class="submit ${properties.kcButtonClass!} ${properties.kcButtonPrimaryClass!} ${properties.kcButtonBlockClass!} ${properties.kcButtonLargeClass!}" name="login" type="submit" value="${msg("doSubmit")}"/>
          </div>
          <div id="kc-info" class="register ${properties.kcSignUpClass!}">
              <div id="kc-info-wrapper" class="${properties.kcInfoAreaWrapperClass!}">
                  <div id="kc-registration">
                      <span><a href="${url.loginUrl}">${msg("backToLogin")?no_esc}</a></span>
                  </div>
              </div>
          </div>
        </form>
  </div>
</#if>
</@layout.registrationLayout>
