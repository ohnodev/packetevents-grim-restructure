package io.github.retrooper.packetevents.handler;

import com.github.retrooper.packetevents.PacketEvents;
import com.github.retrooper.packetevents.protocol.PacketSide;
import com.github.retrooper.packetevents.protocol.player.User;
import com.github.retrooper.packetevents.util.PacketEventsImplHelper;
import io.github.retrooper.packetevents.util.viaversion.ViaVersionUtil;
import io.netty.buffer.ByteBuf;
import io.netty.channel.ChannelHandler;
import io.netty.channel.ChannelHandlerContext;
import io.netty.handler.codec.MessageToMessageDecoder;
import org.jetbrains.annotations.ApiStatus;

import java.util.List;

@ApiStatus.Internal @ChannelHandler.Sharable
public class PacketDecoder extends MessageToMessageDecoder<ByteBuf> implements PacketEventsChannelHandler {

    private final PacketSide side;
    private User user;
    private Object player;
    private final boolean preViaVersion;

    public PacketDecoder(PacketSide side, User user, boolean preViaVersion) {
        this.side = side.getOpposite();
        this.user = user;
        this.preViaVersion = preViaVersion;
    }

    public PacketDecoder(PacketSide side, User user) {
        this(side, user, false);
    }

    @Override
    public User getUser() { return user; }
    @Override
    public void setUser(User user) { this.user = user; }
    @Override
    public Object getPlayer() { return player; }
    @Override
    public void setPlayer(Object player) { this.player = player; }

    @Override
    protected void decode(ChannelHandlerContext ctx, ByteBuf msg, List<Object> out) throws Exception {
        if (!msg.isReadable()) {
            return;
        }
        if (!preViaVersion && PacketEvents.getAPI().getSettings().isPreViaInjection() && !ViaVersionUtil.isAvailable(user)) {
            PacketEventsImplHelper.handleServerBoundPacket(ctx.channel(), user, player, msg, false);
        }
        PacketEventsImplHelper.handlePacket(ctx.channel(), this.user, this.player,
                msg, !preViaVersion, this.side);
        if (msg.isReadable()) {
            out.add(msg.retain());
        }
    }

    @Override
    public void userEventTriggered(ChannelHandlerContext ctx, Object evt) throws Exception {
        super.userEventTriggered(ctx, evt);
    }
}
