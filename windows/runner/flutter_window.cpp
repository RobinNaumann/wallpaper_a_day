#include "flutter_window.h"
#include <windows.h>
#include <iostream>
#include <flutter/event_channel.h>
#include <flutter/event_sink.h>
#include <flutter/event_stream_handler_functions.h>
#include <flutter/method_channel.h>
#include <flutter/standard_method_codec.h>

#include <optional>
#include <memory>

#include "flutter/generated_plugin_registrant.h"

#include <windows.h>
#include <shobjidl.h>
#include <shlguid.h>
#include <shlobj.h>
#include <objbase.h>
#include <string>

#include <tchar.h>  

void AlreadyRunningGuard()
{
    // Unique name for your app's mutex
    const TCHAR* mutexName = _T("in.robbb.wad");

    // Try to create the mutex
    HANDLE hMutex = CreateMutex(NULL, FALSE, mutexName);

    if (hMutex == NULL)
    {
        MessageBox(NULL, _T("Failed to create mutex."), _T("Error"), MB_OK | MB_ICONERROR);
        exit(1); // Exit the application
    }

    // Check if mutex already exists
    if (GetLastError() == ERROR_ALREADY_EXISTS)
    {
        // Another instance is running
        MessageBox(NULL, _T("The application is already running. Check the tray"), _T("Warning"), MB_OK | MB_ICONWARNING);
        CloseHandle(hMutex);
        exit(0); // Exit the application
    }
}

std::wstring GetStartupFolder() {
    wchar_t path[MAX_PATH];
    SHGetFolderPathW(NULL, CSIDL_STARTUP, NULL, 0, path);
    return path;
}

std::wstring GetExePath() {
    wchar_t path[MAX_PATH];
    GetModuleFileNameW(NULL, path, MAX_PATH);
    return path;
}

bool CreateShortcut(const std::wstring& shortcutPath, const std::wstring& targetPath) {
    CoInitialize(NULL);
    IShellLink* pShellLink = nullptr;
    IPersistFile* pPersistFile = nullptr;
    if (FAILED(CoCreateInstance(CLSID_ShellLink, NULL, CLSCTX_INPROC_SERVER,
                               IID_IShellLink, (void**)&pShellLink))) {
        CoUninitialize();
        return false;
    }
    pShellLink->SetPath(targetPath.c_str());
    pShellLink->SetDescription(L"Auto-start app");

    if (FAILED(pShellLink->QueryInterface(IID_IPersistFile, (void**)&pPersistFile))) {
        pShellLink->Release();
        CoUninitialize();
        return false;
    }

    bool success = SUCCEEDED(pPersistFile->Save(shortcutPath.c_str(), TRUE));
    pPersistFile->Release();
    pShellLink->Release();
    CoUninitialize();
    return success;
}

bool AddToStartup() {
    std::wstring startup = GetStartupFolder();
    std::wstring shortcut = startup + L"\\MyApp.lnk";
    std::wstring exePath = GetExePath();
    return CreateShortcut(shortcut, exePath);
}

bool RemoveFromStartup() {
    std::wstring startup = GetStartupFolder();
    std::wstring shortcut = startup + L"\\MyApp.lnk";
    return DeleteFileW(shortcut.c_str()) == TRUE;
}

bool IsInStartup() {
    std::wstring startup = GetStartupFolder();
    std::wstring shortcut = startup + L"\\MyApp.lnk";
    return GetFileAttributesW(shortcut.c_str()) != INVALID_FILE_ATTRIBUTES;
}

static int SetWallpaper(const std::string path) {
  int result;
  result = SystemParametersInfoA(SPI_SETDESKWALLPAPER, 0, (void *)path.c_str(), SPIF_UPDATEINIFILE);
  std::cout << result;
  return result;
}

FlutterWindow::FlutterWindow(const flutter::DartProject& project)
    : project_(project) {}

FlutterWindow::~FlutterWindow() {}

bool FlutterWindow::OnCreate() {
  if (!Win32Window::OnCreate()) {
    return false;
  }

  AlreadyRunningGuard();

  RECT frame = GetClientArea();

  // The size here must match the window dimensions to avoid unnecessary surface
  // creation / destruction in the startup path.
  flutter_controller_ = std::make_unique<flutter::FlutterViewController>(
      frame.right - frame.left, frame.bottom - frame.top, project_);
  // Ensure that basic setup of the controller was successful.
  if (!flutter_controller_->engine() || !flutter_controller_->view()) {
    return false;
  }
  RegisterPlugins(flutter_controller_->engine());

  flutter::MethodChannel<> channel(
      flutter_controller_->engine()->messenger(), "in.robbb.wad",
      &flutter::StandardMethodCodec::GetInstance());
  channel.SetMethodCallHandler(
      [](const flutter::MethodCall<>& call,
         std::unique_ptr<flutter::MethodResult<>> result) {
        if (call.method_name() == "setWallpaper") {
          const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          auto arg_it = arguments->find(flutter::EncodableValue("path"));
          const std::string* arg_str = std::get_if<std::string>(&arg_it->second);
          
          if (!arg_str) {
            result->Error("INVALID_ARGUMENT", "Expected string argument.");
            return;
          }
          int result_code = SetWallpaper(*arg_str);
          if (result_code != -1) {
            result->Success();
          } else {
            result->Error("UNAVAILABLE", "Wallpaper could not be set.");
          }
        } else if (call.method_name() == "setAutostart") {
          const auto* arguments = std::get_if<flutter::EncodableMap>(call.arguments());
          auto arg_it = arguments->find(flutter::EncodableValue("on_login"));
          const bool* arg_bool = std::get_if<bool>(&arg_it->second);
          
          if (!arg_bool) {
            result->Error("INVALID_ARGUMENT", "Expected bool argument.");
            return;
          }
          bool success;
          if (*arg_bool) {
            success = AddToStartup();
          } else {
            success = RemoveFromStartup();
          }
          if (success) {
            result->Success();
          } else {
            result->Error("UNAVAILABLE", "Could not update autostart setting.");
          }
        } else if (call.method_name() == "getAutostart") {
          bool is_enabled = IsInStartup();
          result->Success(flutter::EncodableValue(is_enabled));
        } else {
          result->NotImplemented();
        }
      });

  SetChildContent(flutter_controller_->view()->GetNativeWindow());

  flutter_controller_->engine()->SetNextFrameCallback([&]() {
    this->Show();
  });

  // Flutter can complete the first frame before the "show window" callback is
  // registered. The following call ensures a frame is pending to ensure the
  // window is shown. It is a no-op if the first frame hasn't completed yet.
  flutter_controller_->ForceRedraw();

  return true;
}

void FlutterWindow::OnDestroy() {
  if (flutter_controller_) {
    flutter_controller_ = nullptr;
  }

  Win32Window::OnDestroy();
}

LRESULT
FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
                              WPARAM const wparam,
                              LPARAM const lparam) noexcept {
  // Give Flutter, including plugins, an opportunity to handle window messages.
  if (flutter_controller_) {
    std::optional<LRESULT> result =
        flutter_controller_->HandleTopLevelWindowProc(hwnd, message, wparam,
                                                      lparam);
    if (result) {
      return *result;
    }
  }

  switch (message) {
    case WM_FONTCHANGE:
      flutter_controller_->engine()->ReloadSystemFonts();
      break;
  }

  return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}


