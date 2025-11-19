@echo off

echo TEST :1 Setting up Certificate Authority...
python main.py setup-ca
if %errorlevel% neq 0 (
    echo ERROR: CA setup failed
    exit /b 1
)
echo PASSED
echo.

echo TEST :2 Displaying CA information...
python main.py ca-info
if %errorlevel% neq 0 (
    echo ERROR: CA info failed
    exit /b 1
)
echo PASSED
echo.

echo TEST :3 Issuing certificate for alice...
python main.py issue-cert alice
if %errorlevel% neq 0 (
    echo ERROR: Certificate issuance for alice failed
    exit /b 1
)
echo PASSED
echo.

echo TEST :4 Issuing certificate for bob...
python main.py issue-cert bob
if %errorlevel% neq 0 (
    echo ERROR: Certificate issuance for bob failed
    exit /b 1
)
echo PASSED
echo.

echo TEST :5 Listing all users...
python main.py list-users
if %errorlevel% neq 0 (
    echo ERROR: List users failed
    exit /b 1
)
echo PASSED
echo.

echo TEST :6 Creating test document...
echo This is a test document for PKI signing. > test_document.txt
echo Test document created
echo.

echo TEST :7 Signing document with alice...
python main.py sign alice test_document.txt
if %errorlevel% neq 0 (
    echo ERROR: Document signing failed
    exit /b 1
)
echo PASSED
echo.

echo TEST :8 Verifying alice's signature...
python main.py verify alice test_document.txt pkidocumentstest_document_alice.sig
if %errorlevel% neq 0 (
    echo ERROR: Signature verification failed
    exit /b 1
)
echo PASSED
echo.

echo TEST :9 Revoking bob's certificate...
python main.py revoke-cert bob
if %errorlevel% neq 0 (
    echo ERROR: Certificate revocation failed
    exit /b 1
)
echo PASSED
echo.

echo TEST :10 Listing users after revocation...
python main.py list-users
if %errorlevel% neq 0 (
    echo ERROR: List users after revocation failed
    exit /b 1
)
echo PASSED
echo.

echo ====================================
echo All tests completed successfully!
echo ====================================
echo.

echo Cleanup test document...
del test_document.txt

echo.
echo Test artifacts location: .pki
echo - CA certificates: .pkicacerts
echo - User certificates: .pkiusers
echo - Signatures: .pkidocuments
