package io.github.retrooper.packetevents.factory.fabric;

import com.github.retrooper.packetevents.PacketEvents;
import io.github.retrooper.packetevents.manager.AbstractFabricPlayerManager;
import net.minecraft.network.chat.Component;
import net.minecraft.server.level.ServerPlayer;
import org.jetbrains.annotations.NotNull;

public class FabricPlayerManager extends AbstractFabricPlayerManager {

    public FabricPlayerManager() {
        super(FabricPacketEventsAPI.getServerAPI());
    }

    @Override
    public int getPing(@NotNull Object player) {
        if (player instanceof ServerPlayer sp) {
            return sp.connection.latency();
        }
        throw new UnsupportedOperationException("Unsupported player implementation: " + player);
    }

    @Override
    public Object getChannel(@NotNull Object player) {
        if (player instanceof ServerPlayer sp) {
            return sp.connection.connection.channel;
        }
        throw new UnsupportedOperationException("Unsupported player implementation: " + player);
    }

    @Override
    public void disconnectPlayer(Object serverPlayer, String message) {
        if (serverPlayer instanceof ServerPlayer sp) {
            sp.connection.disconnect(Component.literal(message));
        }
    }
}
