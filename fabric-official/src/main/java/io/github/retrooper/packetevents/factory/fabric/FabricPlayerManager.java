package io.github.retrooper.packetevents.factory.fabric;

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
        return ((ServerPlayer) player).connection.latency();
    }

    @Override
    public Object getChannel(@NotNull Object player) {
        return ((ServerPlayer) player).connection.connection.channel;
    }

    @Override
    public void disconnectPlayer(Object serverPlayer, String message) {
        ((ServerPlayer) serverPlayer).connection.disconnect(Component.literal(message));
    }

    @Override
    public void kickOnException(Object player, String message) {
        ServerPlayer sp = (ServerPlayer) player;
        sp.getServer().execute(() -> disconnectPlayer(sp, message));
    }
}
