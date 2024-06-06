//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <audio_progress_bar/audio_progress_bar_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) audio_progress_bar_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AudioProgressBarPlugin");
  audio_progress_bar_plugin_register_with_registrar(audio_progress_bar_registrar);
}
