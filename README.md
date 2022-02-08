# fido-idp4-demo
This is a webauthn IDP4 demo based on the https://github.com/sipatel2/shibboleth-webauthn project from Duke.  This is customized to use NIEF attributes, is preconfigured with use of the NIEF Testbed, and will add more demo specific configuration in the future.

To build and run the IDP:
  
    docker build --rm -t my/shibb-idp-tier .
    docker run -d --name shib-idp -p 443:443 my/shibb-idp-tier  

## WARNING

This project includes certs and keys used for demoing.  These must not be used in any sort of production capacity as the keys are essentially public domain now.
`
